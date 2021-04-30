SELECT
	[Source]
	, TransactieTypeKey
	, Aantal = COUNT(*)
FROM
	DWH_Quadraam.Fact.Mutatie
GROUP BY
	[Source]
	, TransactieTypeKey

SELECT
	*
FROM
	DWH_Quadraam.Dim.TransactieType