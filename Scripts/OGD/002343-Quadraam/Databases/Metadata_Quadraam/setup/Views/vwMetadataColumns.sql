CREATE VIEW [setup].[vwMetadataColumns]
AS
SELECT
	TABLE_SCHEMA = DataSource
	, TABLE_NAME
	, COLUMN_NAME
	, DATA_TYPE
	, ORDINAL_POSITION
	, OriginalColumnName
FROM
	setup.Metadata