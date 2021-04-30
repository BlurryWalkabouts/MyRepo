CREATE PROCEDURE [etl].[LoadFactMutatie]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.Mutatie

SET XACT_ABORT ON
INSERT INTO
	[$(DWH_Quadraam)].Fact.Mutatie
	(
	BoekDatumKey
	, FactuurDatumKey
	, DagboekKey
	, GrootboekKey
	, KostenplaatsKey
	, KostendragerKey
	, ScenarioKey
	, TransactieTypeKey
	, [FactuurKey]
	, MutatieOmschrijving
	, BegrotingOpmerking
	, MutatieBedrag
	, Boekstuknummer
	, [Source]
	)
SELECT
	BoekDatumKey = COALESCE(bd.DatumKey, -1)
	, FactuurDatumKey = COALESCE(fd.DatumKey, -1)
	, DagboekKey = -1
	, GrootboekKey = COALESCE(gb.GrootboekKey, -1)
	, KostenplaatsKey = COALESCE(kp.KostenplaatsKey, -1)
	, KostendragerKey = COALESCE(kd.KostendragerKey, -1)
	, ScenarioKey = COALESCE(bs.ScenarioKey, -1)
	, TransactieTypeKey = CASE
			WHEN m.transtype = 'N' THEN 3 -- Realisatie
			WHEN m.transtype = 'B' AND bs.ScenarioNaam LIKE 'Begroting%' THEN 1 -- Begroting
			WHEN m.transtype = 'B' AND bs.ScenarioNaam LIKE 'Forecast%' THEN 2 -- Forecast
			ELSE -1 --Onbekend
		END
	, [FactuurKey] = -1
	, MutatieOmschrijving = COALESCE(m.oms25, '')
	, BegrotingOpmerking = ''
	, MutatieBedrag = m.bdr_hfl
	, Boekstuknummer = ''
	, [Source] = 'E'
FROM
	[$(Exact)].dbo.gbkmut m
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Datum bd ON m.docdate = bd.Datum
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Datum fd ON m.datum = fd.Datum
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Grootboek gb ON LTRIM(RTRIM(m.reknr)) = gb.GrootboekRekeningCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON m.kstplcode = kp.KostenplaatsCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostendrager kd ON m.kstdrcode = kd.KostendragerCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Scenario bs ON m.bud_vers = bs.ScenarioCode AND bs.[Source] = 'E'

UNION ALL

SELECT
	BoekDatumKey = COALESCE(bd.DatumKey, -1)
	, FactuurDatumKey = COALESCE(fd.DatumKey, -1)
	, DagboekKey = COALESCE(db.DagboekKey, -1)
	, GrootboekKey = COALESCE(gb.GrootboekKey, -1)
	, KostenplaatsKey = COALESCE(kp.KostenplaatsKey, -1)
	, KostendragerKey = COALESCE(kd.KostendragerKey, -1)
	, ScenarioKey = -1
	, TransactieTypeKey = 3 -- Realisatie
	, [FactuurKey] = COALESCE(f.FactuurKey, -1)
	, MutatieOmschrijving = COALESCE(m.[Description], '')
	, BegrotingOpmerking = ''
	, MutatieBedrag = m.Bedrag_debet
	, Boekstuknummer = COALESCE(m.VoucherNo, '')
	, [Source] = 'A'
FROM
	[$(Staging_Quadraam)].Afas.DWH_FIN_Mutaties m
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Datum bd ON m.EntryDate = bd.Datum
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Datum fd ON m.VoucherDate = fd.Datum
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dagboek db ON m.JournalId = db.DagboekCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Grootboek gb ON m.AccountNo = gb.GrootboekRekeningCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON m.DimAx1 = kp.KostenplaatsCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostendrager kd ON m.DimAx2 = kd.KostendragerCode
--	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Scenario bs ON '001' = bs.ScenarioCode AND bs.[Source] = 'A'
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Factuur f ON f.FactuurNummer = m.InvoiceId

UNION ALL

SELECT 

	BoekDatumKey			= COALESCE(CAST(m.MaandKey AS VARCHAR(8))+'01', -1)
	, FactuurDatumKey		= COALESCE(CAST(m.MaandKey AS VARCHAR(8))+'01', -1)
	, DagboekKey			= -1
	, GrootboekKey			= COALESCE(gb.GrootboekKey, -1)
	, KostenplaatsKey		= COALESCE(kp.KostenplaatsKey, -1)
	, KostendragerKey		= -1
	, ScenarioKey			= -1
	, TransactieTypeKey		= 1 -- Begroting
	, [FactuurKey]			= -1
	, MutatieOmschrijving	= ''
	, BegrotingOpmerking	= COALESCE(tb.opmerking, '') 
	, MutatieBedrag			= CAST(ROUND(bedrag / 12, 4) AS DECIMAL(12,4))
	, Boekstuknummer		= ''
	, [Source]				= 'C'

FROM [$(DWH_Quadraam)].Dim.Maand m
LEFT OUTER JOIN [$(Staging_Quadraam)].[Capisci].[Begroting] b ON m.JaarNum = b.jaar
LEFT OUTER JOIN [$(Staging_Quadraam)].[Capisci].[Toelichtingen_Begroting] tb ON 
				tb.jaar_van <= m.JaarNum 
			AND tb.jaar_tot >= m.JaarNum
			AND tb.kostenplaats = b.kostenplaats
			AND tb.rekening = b.rekening
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON b.kostenplaats = kp.KostenplaatsCode
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Grootboek gb ON b.rekening = gb.GrootboekRekeningCode

WHERE b.kostenplaats IS NOT NULL

UNION ALL

-- LET OP: de ETL van de XML-import draait vaker dan de rest van de ETL 
SELECT 
	BoekDatumKey			= COALESCE(CAST(m.MaandKey AS VARCHAR(8))+'01', -1)
	, FactuurDatumKey		= COALESCE(CAST(m.MaandKey AS VARCHAR(8))+'01', -1)
	, DagboekKey			= -1
	, GrootboekKey			= COALESCE(gb.GrootboekKey, -1)
	, KostenplaatsKey		= COALESCE(kp.KostenplaatsKey, -1)
	, KostendragerKey		= -1
	, ScenarioKey			= -1
	, TransactieTypeKey		= 2 -- Forecast
	, [FactuurKey]			= -1
	, MutatieOmschrijving	= COALESCE(f.Toelichting, '')
	, BegrotingOpmerking	= '' 
	, MutatieBedrag			= COALESCE(f.MutatieBedrag, 0)
	, Boekstuknummer		= ''
	, [Source]				= 'X'

FROM [$(Archive_Quadraam)].[SharePoint].[Forecast] f
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Grootboek gb ON f.GrootboekRekeningCode = gb.GrootboekRekeningCode
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON f.KostenplaatsCode = kp.KostenplaatsCode
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Maand m ON m.JaarNum = f.Jaar AND m.MaandNum = f.Maand

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
END CATCH	
RETURN 0
END