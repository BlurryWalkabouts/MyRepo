CREATE VIEW [setup].[vwDefaultColumnTranslations]
AS
SELECT
	FI_StagingTableName
	, DWColumn
	, FI_SourceColumn
	, SourceDatabaseDWKey = NULL
	, SourceDatabase = NULL
FROM
	setup.DWColumnDefinition
WHERE 1=1
	AND Import = 1
	AND FI_SourceColumn IS NOT NULL