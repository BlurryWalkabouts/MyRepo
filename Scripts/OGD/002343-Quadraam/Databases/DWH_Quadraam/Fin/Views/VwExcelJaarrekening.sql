CREATE VIEW [Fin].[VwExcelJaarrekening]
AS

SELECT
	ID = -1
	, Class_02 = gb.EFJ_RubriekCode
	, EFJ_HoofdrubriekNaam = gb.EFJ_HoofdrubriekNaam
	, EFJ_HoofdrubriekCode = gb.EFJ_HoofdrubriekCode
	, jaar = bd.JaarNum
	, bkjrcode = fd.JaarNum
	, Boekstuknummer = m.Boekstuknummer
	, Inkoopnummer = f.FactuurNummer
	, reknr = gb.GrootboekRekeningCode
	, reknr_omschrijving = gb.GrootboekRekeningNaam
	, docdate = bd.Datum
	, datum = fd.Datum
	, periode = fd.MaandNum
	, periode2 = bd.MaandNum
	, oms25 = m.MutatieOmschrijving
	, bdr_hfl = CASE m.Source WHEN 'X' THEN m.MutatieBedrag * -1 ELSE m.MutatieBedrag END
	, afdeling = CASE LEFT(kp.KostenplaatsCode,3) WHEN '***' THEN '100' ELSE LEFT(kp.KostenplaatsCode,3) END
	, kstplcode = CASE kp.KostenplaatsCode WHEN '*****' THEN '0' ELSE kp.KostenplaatsCode END
	, KostenplaatsNaam = kp.KostenplaatsNaam
	, Instelling = kp.Instelling
	, bud_vers = bs.ScenarioCode
	, TransactionType = tt.TransactieTypeCode
	, transtype = tt.TransactieTypeCode
	, transsubtype = tt.TransactieTypeCode
	, source = m.Source
	, DagboekCode = db.DagboekCode
FROM
	Fact.Mutatie m
	LEFT OUTER JOIN Dim.Datum bd ON m.BoekDatumKey = bd.DatumKey
	LEFT OUTER JOIN Dim.Datum fd ON m.FactuurDatumKey = fd.DatumKey
	LEFT OUTER JOIN Dim.Grootboek gb ON m.GrootboekKey = gb.GrootboekKey
	LEFT OUTER JOIN Dim.Kostenplaats kp ON m.KostenplaatsKey = kp.KostenplaatsKey
	LEFT OUTER JOIN Dim.Scenario bs ON m.ScenarioKey = bs.ScenarioKey
	LEFT OUTER JOIN Dim.TransactieType tt ON m.TransactieTypeKey = tt.TransactieTypeKey
	LEFT OUTER JOIN Dim.Dagboek db ON m.DagboekKey = db.DagboekKey
	LEFT OUTER JOIN Dim.Factuur f ON m.FactuurKey = f.FactuurKey
WHERE 1=1
	AND fd.JaarNum > 2011
	AND fd.JaarNum <= YEAR(GETDATE())