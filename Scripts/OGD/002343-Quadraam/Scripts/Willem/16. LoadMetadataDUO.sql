/*
INSERT INTO [Staging_Quadraam].setup.Metadata
(
	DataSource
	, Connector
	, [Description]
	, ID
	, FieldID
	, DataType
	, Label
	, [Length]
	, ControlType
	, Decimals
	, DecimalsFieldID
)
*/
SELECT DISTINCT
	DataSource = j.DataSource
	, Connector = t.TableName
--	, JSON_VALUE(j.BulkColumn,'$."@id"')
--	, JSON_QUERY(j.BulkColumn,'$."@context"')
	, [Description] = t.Connector --CONCAT(TableName, '_' + CAST(MIN(Jaar1) OVER (PARTITION BY TableName) AS char(4)), '_' + CAST(MAX(Jaar2) OVER (PARTITION BY TableName) AS char(4)))
	, ID = UPPER(w.[key])
	, FieldID = REPLACE(RIGHT(w.[value], CHARINDEX('/',REVERSE(w.[value]))-1),'Fte''','FTE')
	, DataType = 'string'
	, Label = ''
	, [Length] = 100
	, ControlType = 0
	, Decimals = 0
	, DecimalsFieldID = ''
FROM
	[Staging_Quadraam].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn) k
	CROSS APPLY OPENJSON(k.[value]) w
	CROSS APPLY setup.TransformTableNameDUO(j.Connector) t
WHERE 1=1
	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Metadata'
	AND k.[key] = '@context'
	AND w.[key] <> 'results'
ORDER BY
	TableName
	, ID