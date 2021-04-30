CREATE PROCEDURE [monitoring].[LoadReportServerCatalog]
AS
BEGIN

TRUNCATE TABLE monitoring.ReportServerCatalog

-- The first CTE gets the content as a varbinary(max) as well as the other important columns for all reports, data sources and shared datasets.

;WITH ItemContentXML AS
(
SELECT
	cat.ItemID
	, cat.[Name]
	, cat.[Path]
	, cat.[Description]
	, cat.[Type]
	, TypeDescription = CASE cat.[Type]
			WHEN 1 THEN 'Folder'
			WHEN 2 THEN 'Report'
			WHEN 3 THEN 'File / Resource'
			WHEN 4 THEN 'Linked Report'
			WHEN 5 THEN 'Data Source'
			WHEN 6 THEN 'Report Model'
			WHEN 8 THEN 'Shared Dataset'
			WHEN 9 THEN 'Report Part > ' + cat.SubType
			ELSE 'Other'
		END 
	, OriginalReportName = src.[Name]
	, OriginalReportPath = src.[Path]
	, ReportPartComponentID = cat.ComponentID
--	, cat.[Hidden]
	, cat.CreationDate
	, CreatedBy = u1.UserName
	, ChangeDate = cat.ModifiedDate
	, ChangedBy = u2.UserName
	, ContentXML = CONVERT(xml, CONVERT(varbinary(max), cat.Content))
--	, Properties = CONVERT(xml, cat.Property)
	, [Parameters] = CONVERT(xml, cat.Parameter)
FROM
	[$(ReportServer)].[$(ReportDWH)].dbo.[Catalog] cat
	LEFT JOIN [$(ReportServer)].[$(ReportDWH)].dbo.[Catalog] src ON cat.LinkSourceID = src.ItemID
	LEFT OUTER JOIN [$(ReportServer)].[$(ReportDWH)].dbo.Users u1 ON cat.CreatedByID = u1.UserID
	LEFT OUTER JOIN [$(ReportServer)].[$(ReportDWH)].dbo.Users u2 ON cat.ModifiedByID = u2.UserID
WHERE 1=1
	AND cat.[Type] <> 1
)

-- Now use the XML data type to extract the queries, and their command types and text...
INSERT INTO
	monitoring.ReportServerCatalog
	(
	ItemID
	, [Name]
	, [Path]
	, [Description]
	, [Type]
	, TypeDescription
	, OriginalReportName
	, OriginalReportPath
	, ReportPartComponentID
	, CreationDate
	, CreatedBy
	, ChangeDate
	, ChangedBy
	, ContentXML
	, CommandType
	, CommandText
	, Parameter
	)
SELECT
	ItemID
	, [Name]
	, [Path]
	, [Description]
	, [Type]
	, TypeDescription
	, OriginalReportName
	, OriginalReportPath
	, ReportPartComponentID
	, CreationDate
	, CreatedBy
	, ChangeDate
	, ChangedBy
	, ContentXML
	, CommandType = ISNULL(Query.value('(./*:CommandType/text())[1]','nvarchar(1024)'),'Query')
	, CommandText = Query.value('(./*:CommandText/text())[1]','nvarchar(max)')
	, [Parameters]
FROM
	ItemContentXML
	-- Get all the Query elements (The "*:" ignores any xml namespaces)
	OUTER APPLY ItemContentXML.ContentXML.nodes('//*:Query') Queries(Query) -- OUTER APPLY, want linked reports hebben geen content

END