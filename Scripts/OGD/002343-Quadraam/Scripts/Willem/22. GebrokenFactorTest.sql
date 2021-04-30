SELECT
	DataSource
	, ContentType
	, Connector
--	, BulkColumn
	, ImportDateTime
	, Duration = DATEDIFF(MS, LAG(ImportDateTime) OVER (ORDER BY ImportDateTime), ImportDateTime)
	, Chars = LEN(BulkColumn)
	, CharsPerMs = CAST(1.0*LEN(BulkColumn) / DATEDIFF(MS, LAG(ImportDateTime) OVER (ORDER BY ImportDateTime), ImportDateTime) AS decimal(4,1))
--	, [Skip] = CASE ISJSON(BulkColumn) WHEN 1 THEN JSON_VALUE(BulkColumn,'$.skip') END
--	, [Take] = CASE ISJSON(BulkColumn) WHEN 1 THEN JSON_VALUE(BulkColumn,'$.take') END
--	, Aantal = JSON_VALUE(BulkColumn,'$.skip') + COUNT([key])
--	, k.*
FROM
	Staging_Quadraam.setup.DataObjectsTest do
--	CROSS APPLY OPENJSON(do.BulkColumn, 'lax $.rows') k
WHERE 1=1
	AND DataSource = 'Afas'
ORDER BY
	ImportDateTime DESC

--TRUNCATE TABLE Staging_Quadraam.setup.DataObjectsTest