CREATE VIEW [setup].[DWTables]
AS
SELECT
	ID
--	, [Name]
	, Code
	, product
	, build
	, TABLE_CATALOG
	, TABLE_SCHEMA
	, TABLE_NAME = table_name
	, import
FROM
	[$(MDS)].mdm.DWTables