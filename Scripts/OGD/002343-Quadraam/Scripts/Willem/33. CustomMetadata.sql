SELECT
	DataSource
	, Connector
	, OriginalColumnName
	, TableName
	, ColumnName
	, DataType
	, OrdinalPosition
	, SQLString = 'INSERT INTO setup.CustomMetadata SELECT ''' + DataSource + ''',''' + Connector + ''',''' + OriginalColumnName + ''',''' + TableName + ''',''' + ColumnName + ''',''' + DataType + ''',' + CAST(OrdinalPosition AS varchar(2))
FROM
	Metadata_Quadraam.setup.CustomMetadata
ORDER BY
	OrdinalPosition