CREATE VIEW [HR].[VwPbiVerzuimpercentage]
AS

SELECT
	DatumKey = v.DatumKey
	, MedewerkerKey = dv.MedewerkerKey
	, FTE_Bruto = fte.FTE_Bruto
	, IsVangnetregeling = v.IsVangnetregeling
	, Verzuimduurklasse = v.Verzuimduurklasse
	, FTE_Verzuim = CASE WHEN v.IsVangnetregeling = 1 OR v.Verzuimduurklasse = '731_' THEN 0 ELSE (SUM(fte.FTE_Bruto) - SUM(fte.FTE_BAPO) - SUM(fte.FTE_Spaar_BAPO)) * COALESCE(v.AfwezigheidPercentage, 0) END
	, SaldoWerkgeverskosten = SUM(w.SaldoWerkgeverskosten)
FROM
	Fact.Verzuim v
	LEFT OUTER JOIN Dim.Dienstverband dv ON v.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Dim.Datum d1 ON v.DatumKey = d1.DatumKey
	LEFT OUTER JOIN Dim.Datum d2 ON v.Aanvangsdatum_Verzuim = d2.Datum
	LEFT OUTER JOIN Dim.Functie f ON dv.MedewerkerKey = f.MedewerkerKey AND d1.Datum BETWEEN f.BegindatumFunctie AND f.EinddatumFunctie
	LEFT OUTER JOIN Fact.FTE fte ON f.FunctieKey = fte.FunctieKey AND d1.MaandKey = fte.MaandKey
	OUTER APPLY (
		SELECT SaldoWerkgeverskosten = SUM(w.SaldoWerkgeverskosten)
		FROM Fact.Werkgeverskosten w
		WHERE v.DienstverbandKey = w.DienstverbandKey AND d1.MaandKey = w.MaandKey 
		GROUP BY w.MaandKey, w.DienstverbandKey
		) w
GROUP BY
	v.DatumKey
	, dv.MedewerkerKey
	, fte.FTE_Bruto
	, v.IsVangnetregeling
	, v.Verzuimduurklasse
	, v.AfwezigheidPercentage
	, v.IsVangnetregeling