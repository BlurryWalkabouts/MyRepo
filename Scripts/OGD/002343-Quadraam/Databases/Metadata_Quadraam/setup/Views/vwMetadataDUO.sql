CREATE VIEW [setup].[vwMetadataDUO]
AS
SELECT DISTINCT
	DataSource = j.DataSource
	, Connector = t.Connector
	, OriginalColumnName = UPPER(REPLACE(w.[key],'''','''''')) COLLATE Latin1_General_CI_AS
	, TABLE_NAME = t.TableName
	, COLUMN_NAME = REPLACE(RIGHT(w.[value], CHARINDEX('/',REVERSE(w.[value]))-1),'Fte''','FTE')
	, DATA_TYPE = CAST(NULL AS varchar(35))
	, ORDINAL_POSITION = DENSE_RANK() OVER (PARTITION BY t.TableName ORDER BY UPPER(REPLACE(w.[key],'''','''''')))
FROM
	[$(Staging_Quadraam)].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn) k
	CROSS APPLY OPENJSON(k.[value]) w
	CROSS APPLY setup.TransformTableNameDUO(j.Connector) t
WHERE 1=1
	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Metadata'
	AND k.[key] = '@context'
	AND w.[key] <> 'results'