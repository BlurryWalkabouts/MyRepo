SELECT
	docdate
	, Aantal = COUNT(*)
FROM
	[001].dbo.gbkmut
GROUP BY
	docdate
ORDER BY
	docdate

SELECT
	TransactieTypeNaam
	, TransactieSubtypeNaam
	, Aantal = COUNT(*)
FROM
	[001].dbo.gbkmut m
	LEFT OUTER JOIN [DWH_Quadraam].Dim.TransactieType t1 ON m.transtype = t1.TransactieTypeCode
	LEFT OUTER JOIN [DWH_Quadraam].Dim.TransactieSubtype t2 ON m.transsubtype = t2.TransactieSubtypeCode
GROUP BY
	TransactieTypeNaam
	, TransactieSubtypeNaam
ORDER BY
	TransactieTypeNaam
	, TransactieSubtypeNaam

SELECT
	TransactieTypeNaam
	, TransactieSubtypeNaam
	, Aantal = COUNT(*)
FROM
	[DWH_Quadraam].Fact.Mutatie m
	LEFT OUTER JOIN [DWH_Quadraam].Dim.TransactieType t1 ON m.TransactieTypeKey = t1.TransactieTypeKey
	LEFT OUTER JOIN [DWH_Quadraam].Dim.TransactieSubtype t2 ON m.TransactieSubtypeKey = t2.TransactieSubtypeKey
GROUP BY
	TransactieTypeNaam
	, TransactieSubtypeNaam
ORDER BY
	TransactieTypeNaam
	, TransactieSubtypeNaam