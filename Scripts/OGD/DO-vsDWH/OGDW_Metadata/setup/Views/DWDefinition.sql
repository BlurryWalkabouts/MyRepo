CREATE VIEW [setup].[DWDefinition]
AS
SELECT
	ID
	, [Name]
	, Code
	, DatabaseSystemType
	, DatabaseType
	, DatabaseLabel
	, ConnectionName
	, ConnectionString
	, [Enabled]
FROM
	[$(MDS)].mdm.DWDefinition