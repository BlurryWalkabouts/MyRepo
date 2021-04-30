CREATE PROCEDURE [etl].[LoadFactFormatieBegroting]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.FormatieBegroting

SET XACT_ABORT ON
INSERT INTO
	[$(DWH_Quadraam)].Fact.FormatieBegroting
	(
	MaandKey	
	, KostenplaatsKey								
	, MedewerkerKey				
	, Opmerking					
	, Dienstbetrekking			
	, WTF							
	, TU							
	, BAPO						
	, BegroteFTE_bruto			
	, BegroteFTE_netto			
	, LoonkostenBudget			
	)

SELECT 
	MaandKey					= COALESCE(m.MaandKey, -1)
	, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
	, MedewerkerKey				= COALESCE(mw.MedewerkerKey, -1)
	, Opmerking					= COALESCE(CASE WHEN bf.personeelsnummer > 999999999 THEN CAST(bf.personeelsnummer AS VARCHAR(20)) + ' - ' + [naam] ELSE '[Actief]' END, '')
	, Dienstbetrekking			= COALESCE([code], '')
	, WTF						= COALESCE([wtf], 0)			  
	, TU						= COALESCE([tu], 0)
	, BAPO						= COALESCE([lbp], 0)
	, BegroteFTE_bruto			= COALESCE([wtf], 0) + COALESCE([tu], 0)
	, BegroteFTE_netto			= COALESCE([wtf], 0) + COALESCE([tu], 0) - COALESCE([lbp], 0)
	, LoonkostenBudget			= COALESCE([loonkosten], 0)
FROM [$(Staging_Quadraam)].[Capisci].[Begroting_formatie] bf
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON bf.kostenplaats = kp.KostenplaatsCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Maand m ON bf.periode = m.MaandNum AND bf.jaar = m.JaarNum
	LEFT OUTER JOIN [$(Staging_Quadraam)].SharePoint.CapisciMedewerkers cm ON cm.CapisciMedewerkerID = bf.personeelsnummer AND bf.personeelsnummer IS NOT NULL
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker mw ON mw.MedewerkerCode = CASE WHEN bf.personeelsnummer > 999999999 THEN cm.Personeelsnummer ELSE bf.personeelsnummer END


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