CREATE VIEW [HR].[VwPbiVerzuimPerMaand]
AS

SELECT
	MaandKey = d.MaandKey
	, FunctieKey = f.FunctieKey
	, VerzuimType = v.VerzuimType
	, IsDoorlopendVerzuim = v.IsDoorlopendVerzuim
	, IsVangnetregeling = v.IsVangnetregeling
	, Verzuimduurklasse = v.Verzuimduurklasse
	, FTE_Verzuim = ((MAX(fte.FTE_Bruto) - MAX(fte.FTE_BAPO) - MAX(fte.FTE_Spaar_BAPO)) * v.AfwezigheidPercentage * COUNT(d.DatumKey) * 1.0) / DATEPART(DD,EOMONTH(MAX(d.Datum)))
FROM
	Fact.Verzuim v
	LEFT OUTER JOIN Dim.Datum d ON v.DatumKey = d.DatumKey
	LEFT OUTER JOIN Dim.Functie f ON v.DienstverbandKey = f.DienstverbandKey
	LEFT OUTER JOIN Fact.FTE fte ON f.FunctieKey = fte.FunctieKey AND d.MaandKey = fte.MaandKey
WHERE 1=1
	AND d.Datum BETWEEN DATEADD(YY,-5,GETDATE()) AND EOMONTH(GETDATE())
	AND fte.FTE_Bruto IS NOT NULL
	AND v.IsVangnetregeling = 0
	AND v.Verzuimduurklasse <> '731_'
GROUP BY
	d.MaandKey
	, f.FunctieKey
	, v.Aanvangsdatum_Verzuim
	, v.Hersteldatum_verzuim
	, v.Begindatum_Ziektetijdvak
	, v.Einddatum_Ziektetijdvak
	, v.VerzuimType
	, v.IsDoorlopendVerzuim
	, v.IsVangnetregeling
	, v.AfwezigheidPercentage
	, v.AanwezigheidPercentage
	, v.Verzuimduurklasse