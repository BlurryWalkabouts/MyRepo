CREATE PROCEDURE [etl].[LoadFactVerzuim]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.Verzuim
SET XACT_ABORT ON

;WITH VerzuimFiltered AS (
SELECT DISTINCT
	MedewerkerKey						= COALESCE(m.MedewerkerKey, -1)
	, DienstverbandKey					= COALESCE(dv.DienstverbandKey, -1)	
	, Aanvangsdatum_Verzuim				= CAST(z.Begindatum AS DATE)
	, Hersteldatum_Verzuim				= CAST(COALESCE(z.Einddatum, '99991231') AS DATE)
	, Begindatum_Ziektetijdvak			= CAST(z.Begindatum_connector AS DATE)
	, Einddatum_Ziektetijdvak			= CAST(COALESCE(z.Einddatum_connector, '99991231') AS DATE)
	, VerzuimType						= COALESCE(z.Type_verzuim, '')
	, IsDoorlopendVerzuim				= COALESCE(z.Doorlopend_verzuim, 0)
	, IsVangnetregeling					= COALESCE(z.Vangnetregeling, 0)
	, AfwezigheidPercentage				= COALESCE((100 - z.Aanwezigheid) / 100, 0)
	, AanwezigheidPercentage			= COALESCE(z.Aanwezigheid / 100, 0)
	
	 ,[Totaal_doorlopende_dagen_verzuim]

FROM [$(Staging_Quadraam)].[Afas].[DWH_HR_Ziekteverzuim] z
	
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON z.Medewerker = m.MedewerkerCode
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON
		dv.MedewerkerKey = m.MedewerkerKey
	AND dv.Dienstverband = z.Dienstverband
	AND CAST(z.Begindatum_connector AS DATE) BETWEEN dv.BegindatumContract AND dv.EinddatumContract

WHERE 1=1
	AND z.Medewerker <> '99999'
	AND TRY_CAST(z.Medewerker AS int) IS NOT NULL
	AND m.MedewerkerKey IS NOT NULL
	AND z.Type_verzuim_code <> 'ZW'
	AND DATEDIFF(DAY, CAST(z.Begindatum_connector AS DATE), CAST(COALESCE(z.Einddatum_connector, '99991231') AS DATE)) > 0
)

,VerzuimCorrected AS (
SELECT
	MedewerkerKey					
	, DienstverbandKey			
	, Aanvangsdatum_Verzuim		
	, Hersteldatum_Verzuim		 = DATEADD(DAY, -1, Hersteldatum_Verzuim)
	, Begindatum_Ziektetijdvak	
	, Einddatum_Ziektetijdvak	 = DATEADD(DAY, -1, LEAD(Begindatum_Ziektetijdvak, 1, Hersteldatum_Verzuim) OVER(PARTITION BY MedewerkerKey, DienstverbandKey, Aanvangsdatum_Verzuim, Hersteldatum_Verzuim ORDER BY Begindatum_Ziektetijdvak))
		
	, VerzuimType					
	, IsDoorlopendVerzuim		
	, IsVangnetregeling			
	, AfwezigheidPercentage
	, AanwezigheidPercentage

FROM VerzuimFiltered		
)

INSERT INTO [$(DWH_Quadraam)].Fact.Verzuim
(
	[DatumKey]				
	, [DienstverbandKey]					
	, [Aanvangsdatum_Verzuim]			
    , [Hersteldatum_verzuim]			
    , [Begindatum_Ziektetijdvak]		
    , [Einddatum_Ziektetijdvak]	
	, [VerzuimType]					
	, [IsDoorlopendVerzuim]			
    , [IsVangnetregeling]				
	, [AfwezigheidPercentage]					
	, [AanwezigheidPercentage]					
	, [Verzuimduurklasse]				
)

SELECT
d.DatumKey
, DienstverbandKey = COALESCE(v.DienstverbandKey, -1)
, v.Aanvangsdatum_Verzuim		
, v.Hersteldatum_Verzuim
, v.Begindatum_Ziektetijdvak
, v.Einddatum_Ziektetijdvak		
, v.VerzuimType					
, v.IsDoorlopendVerzuim		
, v.IsVangnetregeling
, AfwezigheidPercentage = MIN(v.AfwezigheidPercentage)
, AanwezigheidPercentage = MAX(v.AanwezigheidPercentage)
, Verzuimduurklasse =
	  CASE 
			WHEN DATEDIFF(DAY, CAST(v.Aanvangsdatum_Verzuim AS DATE), d.Datum) + 1 <= 7 THEN '1_7'
			WHEN DATEDIFF(DAY, CAST(v.Aanvangsdatum_Verzuim AS DATE), d.Datum) + 1 <= 42 THEN '8_42'
			WHEN DATEDIFF(DAY, CAST(v.Aanvangsdatum_Verzuim AS DATE), d.Datum) + 1 <= 91 THEN '43_91'
			WHEN DATEDIFF(DAY, CAST(v.Aanvangsdatum_Verzuim AS DATE), d.Datum) + 1 <= 182 THEN '92_182'
			WHEN DATEDIFF(DAY, CAST(v.Aanvangsdatum_Verzuim AS DATE), d.Datum) + 1 <= 365 THEN '183_365'
			WHEN DATEDIFF(DAY, CAST(v.Aanvangsdatum_Verzuim AS DATE), d.Datum) + 1 <= 730 THEN '366_730'
			WHEN DATEDIFF(DAY, CAST(v.Aanvangsdatum_Verzuim AS DATE), d.Datum) + 1 > 730 THEN '731_'
			ELSE 'n.v.t.'
	  END

FROM [$(DWH_Quadraam)].Dim.Datum d
LEFT OUTER JOIN VerzuimCorrected v ON d.Datum >= v.Begindatum_Ziektetijdvak AND d.Datum <= v.Einddatum_Ziektetijdvak

WHERE d.Datum BETWEEN DATEADD(YEAR,-3,GETDATE()) AND DATEADD(MONTH,2,GETDATE())
AND v.MedewerkerKey IS NOT NULL

GROUP BY
d.DatumKey
, d.Datum				
, v.DienstverbandKey	
, v.Aanvangsdatum_Verzuim		
, v.Hersteldatum_Verzuim
, v.Begindatum_Ziektetijdvak
, v.Einddatum_Ziektetijdvak			
, v.VerzuimType					
, v.IsDoorlopendVerzuim		
, v.IsVangnetregeling

ORDER BY DatumKey

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