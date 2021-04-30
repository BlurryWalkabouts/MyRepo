CREATE FUNCTION [setup].[fnTranslatedColumnDefinitions]
(	
	@SourceDatabaseDWKey int
	, @DWStagingTableName varchar(50)
)
RETURNS TABLE
AS
RETURN

WITH source_trans AS
(
SELECT
	DWStagingTableName
	, DWColumn
	, SourceColumn
FROM
	setup.vwSourceColumnTranslations
WHERE 1=1
	AND SourceDatabaseDWKey = @SourceDatabaseDWKey 
	/* 23 -- " + database["SourceDatabaseDWKey"] + ") " */
)

, default_trans AS
(
SELECT
	FI_StagingTableName
	, DWColumn
	, FI_SourceColumn
FROM
	setup.vwDefaultColumnTranslations
)

, dwCols AS
(
SELECT
	DWColumn
	, FI_StagingTableName
	, BimlTypeSource = ssis_source.BimlType
	, BimlTypeTarget = ssis_target.BimlType
	, CastExpression = '(' + ssis_target.CastToSSIS + CASE WHEN ssis_target.LengthReq = 1 THEN ',' + CONVERT(nvarchar(10), TD_Length) ELSE '' END + ')'
FROM
	setup.DWColumnDefinition dw
	INNER JOIN setup.SSISTypes ssis_source ON dw.FI_Type = ssis_source.SqlType COLLATE SQL_Latin1_General_CP1_CS_AS
	INNER JOIN setup.SSISTypes ssis_target ON dw.TD_Type = ssis_target.SqlType COLLATE SQL_Latin1_General_CP1_CS_AS
)

, all_trans AS
(
SELECT
	DWStagingTableName
	, DWColumn
	, SourceColumn
FROM
	source_trans
UNION
SELECT
	FI_StagingTableName
	, DWColumn
	, FI_SourceColumn
FROM
	default_trans
WHERE 1=1
	AND NOT EXISTS (SELECT * FROM source_trans WHERE source_trans.DWStagingTableName = default_trans.FI_StagingTableName AND source_trans.DWColumn = default_trans.DWColumn)
)

SELECT
	all_trans.DWStagingTableName
	, all_trans.DWColumn
	, all_trans.SourceColumn
	, BimlTypeSource
	, BimlTypeTarget
	, CastExpression
	-- SourceColumnExpression, fixen van timestamp: deze maakt gebruik van de vertaalde SourceColumn.
	, SourceColumnExpression = CASE
			WHEN BimlTypeSource = 'DateTime' AND BimlTypeTarget = 'Int64' THEN 'DATEDIFF("mi",(DT_DBTIMESTAMP)"30/12/1899",' + '[' + SourceColumn + '])'
			ELSE '[' + SourceColumn + ']'
		END
FROM
	all_trans
	LEFT OUTER JOIN dwCols ON all_trans.DWStagingTableName = dwCols.FI_StagingTableName AND all_trans.DWColumn = dwCols.DWColumn
WHERE 1=1
	AND DWStagingTableName = @DWStagingTableName
	/* 'Incidents' -- '" + database["SourceFileType"] + "' " */
	AND SourceColumn IS NOT NULL

/*
SELECT * FROM setup.SSISTypes
*/