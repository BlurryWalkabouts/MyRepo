CREATE PROCEDURE [etl].[LoadFactWerkgeverskosten]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.Werkgeverskosten
SET XACT_ABORT ON

INSERT INTO
	[$(DWH_Quadraam)].Fact.Werkgeverskosten
	(           					
		[MaandKey]	
		, [MaandMutatieKey]
		, [KostenplaatsKey]			
		, [KostendragerKey]			
		, [GrootboekKey]				
		, [LooncomponentKey]
		, [DienstverbandKey]						
		, [MedewerkerKey]
		, [SaldoWerkgeverskosten]		
		, [AantalMutaties]			
	)

SELECT
	MaandKey					= COALESCE(ma1.MaandKey, -1)
	, MaandMutatieKey			= COALESCE(ma2.MaandKey, -1)
	, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
	, KostendragerKey			= COALESCE(kd.KostendragerKey, -1)
	, GrootboekKey				= COALESCE(gb.GrootboekKey, -1)
	, LooncomponentKey			= COALESCE(lc.LooncomponentKey, -1)
	, DienstverbandKey			= COALESCE(ddv.DienstverbandKey, -1)
	, MedewerkerKey					= COALESCE(m.MedewerkerKey, -1)
	, SaldoWerkgeverskosten		= SUM(k.[Bedrag_debet]) - SUM(k.[Bedrag_credit])
	, AantalMutaties			= COUNT(*)

FROM [$(Staging_Quadraam)].[Afas].[DWH_HR_Werkgeverskosten] k 

	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON k.Medewerker = m.MedewerkerCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON k.[Kostenplaats] = kp.KostenplaatsCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostendrager kd ON k.[Kostendrager] = kd.KostendragerCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Grootboek gb ON k.[Grootboekrekening] = gb.GrootboekRekeningCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Looncomponent lc ON k.Looncomponent = lc.Looncomponent
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Maand ma1 ON ma1.JaarNum = k.Jaar_2 AND ma1.MaandNum = k.Periode_2
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Maand ma2 ON ma2.JaarNum = k.Jaar AND ma2.MaandNum = k.Periode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband ddv ON 
		ddv.MedewerkerKey = m.MedewerkerKey
	AND ddv.Dienstverband = k.Dienstverband
	AND (CAST(ma2.MaandKey as CHAR(6))+'01' BETWEEN ddv.BegindatumContract AND ddv.EinddatumContract OR ddv.EinddatumContract IS NULL)
--	AND ddv.ContractVolgnummer = k.contractvolgnummer

GROUP BY
	ma1.MaandKey
	, ma2.MaandKey
	, kp.KostenplaatsKey
	, kd.KostendragerKey
	, gb.GrootboekKey
	, lc.LooncomponentKey
	, ddv.DienstverbandKey
	, m.MedewerkerKey

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