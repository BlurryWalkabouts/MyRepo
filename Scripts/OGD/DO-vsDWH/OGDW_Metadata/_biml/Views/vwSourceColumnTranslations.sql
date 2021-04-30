CREATE VIEW [setup].[vwSourceColumnTranslations]
AS
SELECT
	T.DWStagingTableName
	, T.DWColumn
	, T.SourceColumn
	, SourceDatabaseDWKey = SD.Code
	, T.SourceDatabase
FROM
	[setup].SourceColumnTranslation T
	INNER JOIN setup.SourceDefinition SD ON 1=1
		AND T.SourceDatabase = SD.DatabaseLabel
		AND T.DWStagingTableName = SD.SourceFileType
		AND SD.[Enabled] = 1
		AND SD.SourceType = 'FILE'