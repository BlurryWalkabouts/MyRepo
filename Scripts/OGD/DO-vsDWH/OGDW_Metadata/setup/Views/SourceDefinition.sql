CREATE VIEW [setup].[SourceDefinition]
AS
SELECT
	ID
	, [Name]
	, Code
	, DatabaseLabel
	, DatabaseType
	, SourceType = SourceType_Name
	, MultipleCustomers
	, ImportIncidents
	, ImportChanges
	, ConnectionString
	, ConnectionName
	, [Enabled]
	, Query
	, SourceFileType = ImportFileType_Name
FROM
	[$(MDS)].mdm.SourceDefinition