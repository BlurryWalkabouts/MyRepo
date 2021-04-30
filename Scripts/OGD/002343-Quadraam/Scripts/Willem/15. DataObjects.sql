--2017-10-02

SELECT
	DataSource
	, ContentType
	, Connector
--	, BulkColumn
	, ImportDateTime
	, ImportDuration
	, Duration = DATEDIFF(MS, LAG(ImportDateTime) OVER (ORDER BY ImportDateTime), ImportDateTime)
	, Chars = LEN(BulkColumn)
	, CharsPerMs = CAST(1.0*LEN(BulkColumn) / ImportDuration AS decimal(6,1))
--	, [Skip] = CASE ISJSON(BulkColumn) WHEN 1 THEN JSON_VALUE(BulkColumn,'$.skip') END
--	, [Take] = CASE ISJSON(BulkColumn) WHEN 1 THEN JSON_VALUE(BulkColumn,'$.take') END
--	, Aantal = JSON_VALUE(BulkColumn,'$.skip') + COUNT([key])
--	, k.*
FROM
	Staging_Quadraam.setup.DataObjects do
--	CROSS APPLY OPENJSON(do.BulkColumn, 'lax $.rows') k
WHERE 1=1
	AND DataSource = 'DUO'
--	AND ImportDateTime > '2017-10-02 20:20:00'
/*
GROUP BY
	Connector
	, ContentType
--	, BulkColumn
	, ImportDateTime
	, JSON_VALUE(BulkColumn,'$.skip')
	, JSON_VALUE(BulkColumn,'$.take')
--*/
ORDER BY
	ImportDateTime DESC

/*
DELETE FROM
	setup.DataObjects
WHERE 1=1
	AND DataSource = 'Afas'
	AND ContentType = 'Metadata'
--	AND Connector NOT IN ('DWH_HR_Werkgeverskosten')
*/