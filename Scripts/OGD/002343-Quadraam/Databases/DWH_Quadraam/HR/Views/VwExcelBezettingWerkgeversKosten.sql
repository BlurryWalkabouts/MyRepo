CREATE VIEW [HR].[VwExcelBezettingWerkgeversKosten]
AS

SELECT
	wk.MaandKey
	, wk.KostenplaatsKey
	, wk.KostendragerKey
	, wk.GrootboekKey
	, wk.LooncomponentKey
	, wk.DienstverbandKey
	, wk.SaldoWerkgeverskosten
	, wk.AantalMutaties
	, kpl.KostenplaatsCode
	, kpl.KostenplaatsNaam
	, kpl.BRIN_Nummer
	, kpl.Instelling
	, kpl.VestigingsNummer
	, md.JaarNum
	, md.MaandNum
	, md.MaandNaam
	, kdr.KostendragerCode
	, kdr.KostendragerNaam
	, gb.GrootboekRekeningCode
	, gb.GrootboekRekeningNaam
	, gb.CategorieCode
	, gb.CategorieNaam
	, gb.EFJ_HoofdrubriekCode
	, gb.EFJ_HoofdrubriekNaam
	, gb.EFJ_RubriekCode
	, gb.EFJ_RubriekNaam
	, gb.EFJ_SubrubriekCode
	, gb.EFJ_SubrubriekNaam
	, gb.HRM_SubrubriekCode
	, gb.HRM_SubrubriekNaam
	, lc.Looncomponent
	, lc.Grondslag
	, dv.IsVervanging
	, dv.IsPoolVervanging
	, dv.IsUitbreiding
	, dv.BegindatumContract
	, dv.EinddatumContract
	, dv.Dienstbetrekking
	, dv.VervangtMedewerkerNaam
	, dv.Arbeidsrelatie
	, dv.ContractType
	, dv.ContractVolgnummer
	, dv.RedenEindeDienstverband
	, dv.FTE_Dienstverband
	, dv.MedewerkerKey
	, mdw.MedewerkerCode
	, mdw.MedewerkerNaam
	, mdw.Geslacht
FROM
	Fact.Werkgeverskosten wk
	LEFT OUTER JOIN Dim.Kostenplaats kpl ON wk.KostenplaatsKey = kpl.KostenplaatsKey
	LEFT OUTER JOIN Dim.Maand md ON wk.MaandKey = md.MaandKey
	LEFT OUTER JOIN Dim.Kostendrager kdr ON wk.KostendragerKey = kdr.KostendragerKey
	LEFT OUTER JOIN Dim.Grootboek gb ON wk.GrootboekKey = gb.GrootboekKey
	LEFT OUTER JOIN Dim.Looncomponent lc ON wk.LooncomponentKey = lc.LooncomponentKey
	LEFT OUTER JOIN Dim.Dienstverband dv ON wk.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Dim.Medewerker mdw ON dv.MedewerkerKey = mdw.MedewerkerKey
WHERE 1=1
	AND md.JaarNum > 2016