CREATE VIEW [setup].[vwMetadataAfas]
AS
SELECT
	DataSource = j.DataSource
	, Connector = j.Connector
	, OriginalColumnName = w.id
	, TABLE_NAME = j.Connector
	, COLUMN_NAME = t1.ColumnName
	, DATA_TYPE = t2.DataType
	, ORDINAL_POSITION = DENSE_RANK() OVER (PARTITION BY j.Connector ORDER BY w.fieldId)
	, [Description] = JSON_VALUE(j.BulkColumn,'$.description')
	, ID = w.id
	, FieldID = w.fieldId
	, DataType = w.dataType
	, Label = w.label
	, [Length] = w.[length]
	, ControlType = w.controlType
	, Decimals = w.decimals
	, DecimalsFieldID = w.decimalsFieldId
FROM
	[$(Staging_Quadraam)].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn, 'lax $.fields') k
	CROSS APPLY OPENJSON(k.[value]) WITH
	(
	id                varchar(100)
	, fieldId         varchar(100)
	, dataType        varchar(10)
	, label           varchar(100)
	, [length]        int
	, controlType     int
	, decimals        int
	, decimalsFieldId varchar(10)
	) w
	CROSS APPLY setup.TransformColumnNameAfas(w.id) t1
	CROSS APPLY setup.TransformDataType(w.dataType, w.[length], w.decimals) t2
WHERE 1=1
	AND j.DataSource = 'Afas'
	AND j.ContentType = 'Metadata'