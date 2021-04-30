CREATE PROCEDURE [etl].[LoadDimFunctie]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Functie

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Functie ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Functie 
	(
	FunctieKey			
	, MedewerkerKey	
	, [KostenplaatsKey]		
	, [KostendragerKey]		
	, [DienstverbandKey]				
	, [FunctieOmschrijving]			
	, [FunctieType]			
	, [BegindatumFunctie]		
	, [EinddatumFunctie]
	, FunctiePercentage
	, IsFunctie
	, IsFormatieVerdeling	
	)
VALUES
	(-1, -1, -1, -1, -1, '[Onbekend]', '', '19000101', '99991231', 0, 0, 0)
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Functie OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Functie
	(
	MedewerkerKey	
	, [KostenplaatsKey]		
	, [KostendragerKey]		
	, [DienstverbandKey]				
	, [FunctieOmschrijving]			
	, [FunctieType]			
	, [BegindatumFunctie]		
	, [EinddatumFunctie]
	, FunctiePercentage	
	, IsFunctie
	, IsFormatieVerdeling	
	)

SELECT
	MedewerkerKey					= COALESCE(m.MedewerkerKey, -1)
	, KostenplaatsKey				= COALESCE(kp.KostenplaatsKey, -1)
	, KostendragerKey				= COALESCE(kd.KostendragerKey, -1)
	, DienstverbandKey				= COALESCE(dv.DienstverbandKey, -1)
	, FunctieOmschrijving			= COALESCE(fv.Functie, '')
	, FunctieType					= COALESCE(fv.Type_functie, '')
	, BegindatumFunctie				= COALESCE(CAST(fv.Begindatum AS DATE), '19000101')
	, EinddatumFunctie				= CAST(COALESCE(fv.Einddatum, '99991231') AS DATE)
	, FunctiePercentage				= CAST(COALESCE(fv.[Percentage], 0) / 100 AS DECIMAL(6,5))
	, IsFunctie						= CASE WHEN f.Kostenplaats = fv.Kostenplaats_code THEN 1 ELSE 0 END
	, IsFormatieVerdeling			= CASE WHEN f.Kostenplaats = fv.Kostenplaats_code THEN 0 ELSE 1 END

FROM [$(Staging_Quadraam)].[Afas].[DWH_HR_Functie] f

	LEFT OUTER JOIN [$(Staging_Quadraam)].[Afas].[DWH_HR_Formatieverdeling] fv ON
		f.Medewerker = fv.Medewerker
	AND f.Dienstverband = fv.DV
	AND f.Koppeling_contract = fv.Volgnummer_contract
	AND COALESCE(CAST(fv.Begindatum AS DATE), '19000101') = COALESCE(CAST(f.Begindatum_functie AS DATE), '19000101')
	AND CAST(COALESCE(fv.Einddatum, '99991231') AS DATE) = COALESCE(CAST(f.Einddatum_functie AS DATE), '99991231')
	
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON m.MedewerkerCode = fv.Medewerker
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsCode = fv.Kostenplaats_code
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostendrager kd ON kd.KostendragerCode = fv.Kostendrager_code
	
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON 
		dv.Dienstverband = fv.DV
	AND dv.MedewerkerKey = m.MedewerkerKey
	AND dv.ContractVolgnummer = fv.Volgnummer_contract

WHERE 1=1
	AND f.Medewerker <> '99999'
	AND TRY_CAST(f.Medewerker AS int) IS NOT NULL

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Functie OFF
END CATCH
RETURN 0
END