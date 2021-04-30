CREATE VIEW [Fin].[VwExcelBezettingBegroot_maand]
AS

SELECT
	MaandKey = fb.MaandKey
	, KostenplaatsKey = fb.KostenplaatsKey
	, MedewerkerKey = fb.MedewerkerKey
	, Opmerking = fb.Opmerking
	, Dienstbetrekking = fb.Dienstbetrekking
	, WTF = fb.WTF
	, TU = fb.TU
	, BAPO = fb.BAPO
	, Aanstelling = fb.WTF + fb.TU
	, BegroteFTE_bruto = fb.BegroteFTE_bruto
	, BegroteFTE_netto = fb.BegroteFTE_netto
	, LoonkostenBudget = fb.LoonkostenBudget
	, KostenplaatsCode = kpl.KostenplaatsCode
	, KostenplaatsNaam = kpl.KostenplaatsNaam
	, BRIN_Nummer = kpl.BRIN_Nummer
	, Instelling = kpl.Instelling
	, VestigingsNummer = kpl.VestigingsNummer
	, MedewerkerCode = mdw.MedewerkerCode
	, MedewerkerNaam = CASE mdw.MedewerkerNaam WHEN '[Onbekend]' THEN SUBSTRING(fb.Opmerking,14,LEN(fb.Opmerking)) ELSE mdw.MedewerkerNaam END
	, JaarNum = md.JaarNum
	, MaandNum = md.MaandNum
	, MaandNaam = md.MaandNaam
	, FunctieOmschrijving = COALESCE(f.FunctieOmschrijving, '[Onbekend]')
	, FunctieType = COALESCE(f.FunctieType, '')
FROM
	Fact.FormatieBegroting fb
	LEFT OUTER JOIN Dim.Kostenplaats kpl ON fb.KostenplaatsKey = kpl.KostenplaatsKey
	LEFT OUTER JOIN Dim.Medewerker mdw ON fb.MedewerkerKey = mdw.MedewerkerKey
	LEFT OUTER JOIN Dim.Maand md ON fb.MaandKey = md.MaandKey
	OUTER APPLY (
		SELECT TOP 1 f.FunctieOmschrijving, f.FunctieType
		FROM Dim.Functie f
		WHERE fb.MedewerkerKey = f.MedewerkerKey AND EOMONTH(DATEFROMPARTS(md.JaarNum,md.MaandNum, 1)) BETWEEN f.BegindatumFunctie AND f.EinddatumFunctie
		) f