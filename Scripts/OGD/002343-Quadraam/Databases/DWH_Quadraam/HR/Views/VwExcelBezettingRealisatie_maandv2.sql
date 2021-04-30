CREATE VIEW [HR].[VwExcelBezettingRealisatie_maandv2]
AS

WITH wkcte AS
(
SELECT DISTINCT
	MaandKey = wk.MaandKey
	, MedewerkerKey = mdw.MedewerkerKey
	, KostenplaatsCode = kpl.KostenplaatsCode
	, KostenplaatsNaam = kpl.KostenplaatsNaam
	, SaldoWerkgeverskosten = SUM(wk.SaldoWerkgeverskosten)
	, Dienstbetrekking = dv.Dienstbetrekking
	, MedewerkerCode = mdw.MedewerkerCode
	, MedewerkerNaam = mdw.MedewerkerNaam
	, Leeftijd = FLOOR(DATEDIFF(DD, mdw.Geboortedatum, GETDATE()) / 365.25)
	, FunctieKey = NULL
	, DienstverbandKey = dv.DienstverbandKey
	, VervangtMedewerkerNaam = dv.VervangtMedewerkerNaam
FROM
	Fact.Werkgeverskosten wk
	LEFT OUTER JOIN Dim.Kostenplaats kpl ON wk.KostenplaatsKey = kpl.KostenplaatsKey
	LEFT OUTER JOIN Dim.Dienstverband dv ON wk.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Dim.Medewerker mdw ON dv.MedewerkerKey = mdw.MedewerkerKey
--	LEFT OUTER JOIN Dim.Functie fc ON fc.KostenplaatsKey = wk.KostenplaatsKey AND fc.MedewerkerKey = dv.MedewerkerKey AND wk.DienstverbandKey = fc.DienstverbandKey 
--		AND CONVERT(date,CAST(wk.MaandKey as CHAR(6))+'01',20) BETWEEN fc.BegindatumFunctie AND fc.EinddatumFunctie
--		AND fc.FunctieKey = (SELECT TOP 1 FunctieKey FROM dim.Functie WHERE fc.KostenplaatsKey = wk.KostenplaatsKey AND fc.MedewerkerKey = dv.MedewerkerKey AND (CONVERT(date,CAST(wk.MaandKey as CHAR(6))+'01',20) BETWEEN fc.BegindatumFunctie AND fc.EinddatumFunctie)) AND fc.FunctieKey IS NOT NULL
--	LEFT OUTER JOIN Dim.Functie f ON f.KostenplaatsKey = wk.KostenplaatsKey AND f.MedewerkerKey = dv.MedewerkerKey AND wk.DienstverbandKey = f.DienstverbandKey 
GROUP BY
	wk.MaandKey
	, mdw.MedewerkerKey
	, kpl.KostenplaatsCode
	, kpl.KostenplaatsNaam
	, dv.Dienstbetrekking
	, mdw.MedewerkerCode
	, mdw.MedewerkerNaam
	, mdw.Geboortedatum
	, dv.DienstverbandKey
	, dv.VervangtMedewerkerNaam
)

SELECT DISTINCT
	MaandKey = fte.MaandKey
	, JaarNum = LEFT(fte.MaandKey,4)
	, MaandNum = RIGHT(fte.MaandKey,2)
	, fc.DienstverbandKey
	, MedewerkerKey = fc.MedewerkerKey
	, kpl.KostenplaatsCode
	, kpl.KostenplaatsNaam
	, FTE_TU = SUM(fte.FTE_TU)
	, FTE_Bruto = SUM(fte.FTE_Bruto)
	, FTE_BAPO = SUM(fte.FTE_BAPO)
	, FTE_Spaar_BAPO = SUM(fte.FTE_Spaar_BAPO)
	, FTE_Detachering = SUM(fte.FTE_Detachering)
	, FTE_Spaarverlof = SUM(fte.FTE_Spaarverlof)
	, FTE_Ouderschapsverlof = SUM(fte.FTE_Ouderschapsverlof)
	, FTE_Zwangerschapsverlof = SUM(fte.FTE_Zwangerschapsverlof)
	, FTE_Onbetaald_Verlof = SUM(fte.FTE_Onbetaald_Verlof)
	, FTE_Netto = SUM(fte.FTE_Netto)
	, FunctieOmschrijving = fc.FunctieOmschrijving
	, FunctieType = fc.FunctieType
	, Dienstbetrekking = dd.Dienstbetrekking -- was eerst leeg, nu dd.dienstverband left outer join als test voor excel overzicht
	, VervangtMedewerkerNaam = ''
	, MedewerkerNaam = mdw.MedewerkerNaam
	, MedewerkerCode = mdw.MedewerkerCode
	, SaldoWerkgeverskosten = 0
	, Leeftijd = FLOOR(DATEDIFF(DD, mdw.Geboortedatum, GETDATE()) / 365.25)
	, FunctieKey = fc.FunctieKey
FROM
	Fact.FTE fte
	LEFT OUTER JOIN Dim.Functie fc ON fte.FunctieKey = fc.FunctieKey
	LEFT OUTER JOIN Dim.Kostenplaats kpl ON fc.KostenplaatsKey = kpl.KostenplaatsKey
	LEFT OUTER JOIN Dim.Medewerker mdw ON mdw.MedewerkerKey = fc.MedewerkerKey
	LEFT OUTER JOIN Dim.Dienstverband dd ON dd.DienstverbandKey = fc.DienstverbandKey -- was eerst leeg, nu dd.dienstverband left outer join als test voor excel overzicht
--	LEFT OUTER JOIN wkcte ON wkcte.MaandKey = fte.MaandKey AND fc.MedewerkerKey = wkcte.MedewerkerKey AND wkcte.FunctieKey = fte.FunctieKey --AND fc.DienstverbandKey = wkcte.DienstverbandKey
GROUP BY
	fte.MaandKey
	, fc.DienstverbandKey
	, fc.MedewerkerKey
	, kpl.KostenplaatsCode
	, kpl.KostenplaatsNaam
	, fc.FunctieOmschrijving
	, fc.FunctieType
	, dd.Dienstbetrekking 
	, fc.FunctieKey
	, mdw.MedewerkerNaam
	, mdw.MedewerkerCode
	, mdw.Geboortedatum

UNION

SELECT DISTINCT
	MaandKey = wkcte.MaandKey
	, JaarNum = LEFT(wkcte.MaandKey,4)
	, MaandNum = RIGHT(wkcte.MaandKey,2)
	, DienstverbandKey = wkcte.DienstverbandKey
	, MedewerkerKey = wkcte.MedewerkerKey
	, KostenplaatsCode = wkcte.KostenplaatsCode
	, KostenplaatsNaam = wkcte.KostenplaatsNaam
	, FTE_TU = 0
	, FTE_Bruto = 0
	, FTE_BAPO = 0
	, FTE_Spaar_BAPO = 0
	, FTE_Detachering = 0
	, FTE_Spaarverlof = 0
	, FTE_Ouderschapsverlof = 0
	, FTE_Zwangerschapsverlof = 0
	, FTE_Onbetaald_Verlof = 0
	, FTE_Netto = 0
	, FunctieOmschrijving = 'Onbekend'
	, FunctieType = 'Onbekend'
	, Dienstbetrekking = wkcte.Dienstbetrekking
	, VervangtMedewerkerNaam = wkcte.VervangtMedewerkerNaam
	, MedewerkerNaam = wkcte.MedewerkerNaam
	, MedewerkerCode = wkcte.MedewerkerCode
	, SaldoWerkgeverskosten = COALESCE(SUM(wkcte.SaldoWerkgeverskosten),0)
	, Leeftijd = wkcte.Leeftijd
	, FunctieKey = COALESCE(wkcte.Functiekey,-1)
FROM
	wkcte
GROUP BY
	wkcte.MaandKey
	, wkcte.DienstverbandKey
	, wkcte.MedewerkerKey
	, wkcte.KostenplaatsCode
	, wkcte.KostenplaatsNaam
	, wkcte.functiekey
	, wkcte.Dienstbetrekking
	, wkcte.VervangtMedewerkerNaam
	, wkcte.MedewerkerNaam
	, wkcte.MedewerkerCode
	, wkcte.Leeftijd