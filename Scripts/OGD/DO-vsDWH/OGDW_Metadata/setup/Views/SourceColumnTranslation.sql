CREATE VIEW [setup].[SourceColumnTranslation]
AS
SELECT
	ID
	, [Name]
	, Code
	, SourceDatabase
	, DWStagingTableName
	, DWColumn
	, SourceColumn
FROM
	[$(MDS)].mdm.SourceColumnTranslation