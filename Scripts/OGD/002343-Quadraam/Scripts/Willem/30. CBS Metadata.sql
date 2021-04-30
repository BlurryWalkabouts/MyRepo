;WITH XMLNAMESPACES
(
'http://schemas.microsoft.com/ado/2007/06/edmx' AS edmx
--, 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata' AS m
, 'http://schemas.microsoft.com/ado/2006/04/edm' AS edm
)

, x as
(
SELECT
	BulkColumn = CONVERT(xml, CONVERT(varchar(max), BulkColumn))
--	, BulkColumn
FROM
	Staging_Quadraam.setup.DataObjects do
WHERE 1=1
	AND DataSource = 'CBS'
)

SELECT
	[Name] = p.value('@Name','varchar(64)')
	, [Type] = p.value('@Type','varchar(32)')
--	, x.BulkColumn
FROM
	x
	CROSS APPLY BulkColumn.nodes('/edmx:Edmx/edmx:DataServices/edm:Schema/edm:EntityType[5]/edm:Property') R(p)