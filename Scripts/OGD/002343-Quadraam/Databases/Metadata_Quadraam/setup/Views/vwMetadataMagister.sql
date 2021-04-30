CREATE VIEW [setup].[vwMetadataMagister]
AS
SELECT DISTINCT
	DataSource
	, Connector
	, OriginalColumnName
	, TABLE_NAME = TableName
	, COLUMN_NAME = ColumnName
	, DATA_TYPE = DataType
	, ORDINAL_POSITION = OrdinalPosition
FROM
	setup.CustomMetadata
WHERE 1=1
	AND DataSource = 'Magister'