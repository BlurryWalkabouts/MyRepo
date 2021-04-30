CREATE PROCEDURE [monitoring].[LoadNewReportExecutions]
AS
BEGIN

/* =============================================
 Author:	 Koen Ubbink
 Create date: 18 January 2017
 Description: Insert procedure for SSRS Logging
 =============================================*/

INSERT INTO
	monitoring.ReportExecutions
	(
	LogEntryID
	, ItemPath
	, UserName
	, ReportName
	, RequestType
	, ReportAction
	, TimeStart
	, TimeEnd
	, TimeDataRetrieval
	, TimeProcessing
	, TimeRendering
	, [Source]
	, [Status]
	, ByteCount
	, [RowsCount]
	)
-- Running query using linkedserver.database.schema.table results in an error. Use OPENQUERY instead.
-- "Xml data type is not supported in distributed queries. Remote object 'DWH01_readonly.ReportDWH2016.dbo.ExecutionLogStorage' has xml column(s)."
SELECT
	LogEntryID = e.LogEntryId
	, ItemPath = COALESCE(CASE e.ReportAction
        WHEN 11 THEN AdditionalInfo.value('(AdditionalInfo/SourceReportUri)[1]', 'nvarchar(max)')
        ELSE c.[Path]
        END, 'Unknown')
	, e.UserName
	, ReportName = c.[Name]
	, RequestType = CASE e.RequestType
			WHEN 0 THEN 'Interactive'
			WHEN 1 THEN 'Subscription'
			WHEN 2 THEN 'Refresh Cache'
			ELSE 'Unknown'
		END
	, ReportAction = CASE e.ReportAction
			WHEN 1 THEN 'Render'
			WHEN 2 THEN 'BookmarkNavigation'
			WHEN 3 THEN 'DocumentMapNavigation'
			WHEN 4 THEN 'DrillThrough'
			WHEN 5 THEN 'FindString'
			WHEN 6 THEN 'GetDocumentMap'
			WHEN 7 THEN 'Toggle'
			WHEN 8 THEN 'Sort'
			WHEN 9 THEN 'Execute'
			WHEN 10 THEN 'RenderEdit'
			WHEN 11 THEN 'ExecuteDataShapeQuery'
			ELSE 'Unknown'
		END
	, e.TimeStart
	, e.TimeEnd
	, e.TimeDataRetrieval
	, e.TimeProcessing
	, e.TimeRendering
	, [Source] = CASE e.[Source]
			WHEN 1 THEN 'Live'
			WHEN 2 THEN 'Cache'
			WHEN 3 THEN 'Snapshot'
			WHEN 4 THEN 'History'
			WHEN 5 THEN 'AdHoc'
			WHEN 6 THEN 'Session'
			WHEN 7 THEN 'Rdce'
			ELSE 'Unknown'
		END
	, e.[Status]
	, e.ByteCount
	, e.[RowCount]
FROM
	[$(ReportServer)].[$(ReportDWH)].dbo.ExecutionLogStorage e WITH (NOLOCK)
	LEFT OUTER JOIN [$(ReportServer)].[$(ReportDWH)].dbo.[Catalog] c WITH (NOLOCK) ON e.ReportID = c.ItemID
WHERE 1=1
	AND e.LogEntryId NOT IN (SELECT LogEntryID FROM monitoring.ReportExecutions)
ORDER BY
	LogEntryID

END