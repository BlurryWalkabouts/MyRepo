
CREATE PROCEDURE [etl].[LoadFactFTE]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.FTE

SET XACT_ABORT ON

-- Maak een tabel met alle zwangerschapsverloven uitgesplitst naar datumkey
;WITH Zwangerschapsverlof AS (
SELECT
d.DatumKey
,dv.DienstverbandKey
,IsZwangerschapsverlof = 1
FROM [$(DWH_Quadraam)].Dim.Datum d
LEFT OUTER JOIN [$(Staging_Quadraam)].[Afas].[DWH_HR_Ziekteverzuim] z ON d.Datum BETWEEN CAST(z.Begindatum AS DATE) AND DATEADD(DAY, -1, CAST(COALESCE(z.Einddatum, '99991231') AS DATE))
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON m.MedewerkerCode = z.Medewerker
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON
		dv.MedewerkerKey = m.MedewerkerKey 
	AND d.Datum BETWEEN dv.BegindatumContract AND dv.EinddatumContract
	AND dv.Dienstverband = z.Dienstverband
WHERE
z.Type_verzuim_code = 'ZW'
AND z.Aanwezigheid < 100
AND d.Datum BETWEEN DATEADD(YEAR,-5,GETDATE()) AND EOMONTH(GETDATE())
GROUP BY
d.DatumKey
,dv.DienstverbandKey
)
--SELECT * FROM Zwangerschapsverlof

-- Maak een tabel met alle onbetaalde verloven uitgesplitst naar datumkey
,Onbetaaldverlof AS (
SELECT
d.DatumKey
,dv.DienstverbandKey
,FTE_OnbetaaldVerlof = SUM(v.Waarde / 36.86) --de waarde is in uren per week, een werkweek is 36,86 uur. Deze deling levert een fte op
FROM [$(DWH_Quadraam)].Dim.Datum d
LEFT OUTER JOIN [$(Staging_Quadraam)].[Afas].DWH_HR_Verlof_parameter v ON d.Datum BETWEEN CAST(v.Begindatum AS DATE) AND CAST(COALESCE(v.Einddatum, '99991231') AS DATE)
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON m.MedewerkerCode = v.Medewerker
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON
		dv.MedewerkerKey = m.MedewerkerKey
	AND (dv.Dienstverband = v.Dienstverband OR (v.Dienstverband IS NULL AND dv.IsHoofddienstverband = 1)) --Is er een verschil tussen toepassing_code T en H?
	AND d.Datum BETWEEN dv.BegindatumContract AND dv.EinddatumContract
WHERE 
v.Omschrijving_klant <> 'Ouderschapsverlof uren' --ouderschapsverlof staat ook in deze tabel, deze berekenen we later op andere manier (via kostendrager)
AND v.Waarde NOT IN (1,2,3,4,5)
AND d.Datum BETWEEN DATEADD(YEAR,-5,GETDATE()) AND EOMONTH(GETDATE())
GROUP BY
d.DatumKey
,dv.DienstverbandKey
)
--SELECT * FROM Onbetaaldverlof

-- Maak een tabel met alle rooster records uitgesplitst naar datumkey
,Rooster AS (
SELECT
d.DatumKey
,dv.DienstverbandKey
,FTE_Bruto					= COALESCE(SUM(r.[FTE]), 0)
,FTE_BAPO					= COALESCE(SUM(r.[BAPO_FTE]), 0)
,FTE_Spaar_BAPO				= COALESCE(SUM(r.[Spaar_BAPO_FTE]), 0)
FROM [$(DWH_Quadraam)].Dim.Datum d
LEFT OUTER JOIN [$(Staging_Quadraam)].[Afas].[DWH_HR_Rooster] r ON d.Datum BETWEEN r.Begindatum_rooster AND COALESCE(r.Einddatum_rooster, '99991231')
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON m.MedewerkerCode = r.Medewerker
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON 
		dv.Dienstverband = r.Dienstverband
	AND dv.ContractVolgnummer = r.Koppeling_contract
	AND dv.MedewerkerKey = m.MedewerkerKey
	AND d.Datum BETWEEN dv.BegindatumContract AND dv.EinddatumContract
WHERE 1=1
AND r.Medewerker <> '99999' -- testmedewerker
AND TRY_CAST(r.Medewerker AS int) IS NOT NULL
AND d.Datum BETWEEN DATEADD(YEAR,-5,GETDATE()) AND EOMONTH(GETDATE())
AND dv.DienstverbandKey <> -1
GROUP BY
d.DatumKey
,dv.DienstverbandKey
)
--SELECT * FROM Rooster

-- Maak een tabel met alle functie records uitgesplitst naar datumkey
,Functie AS (
SELECT 
d.DatumKey
, f.FunctieKey
, dv.DienstverbandKey
, f.KostenplaatsKey
, f.KostendragerKey
, dv.IsUitbreiding
, FunctiePercentage = AVG(f.FunctiePercentage)
FROM [$(DWH_Quadraam)].Dim.Datum d
LEFT OUTER JOIN [$(DWH_Quadraam)].[Dim].[Functie] f ON d.Datum >= BegindatumFunctie AND d.Datum <= f.EinddatumFunctie
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON dv.DienstverbandKey = f.DienstverbandKey
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON dv.MedewerkerKey = m.MedewerkerKey
WHERE 
m.MedewerkerCode <> 99999 -- testmedewerker
AND d.Datum BETWEEN DATEADD(YEAR,-5,GETDATE()) AND EOMONTH(GETDATE())
AND FunctieKey <> -1

GROUP BY 
d.DatumKey
, f.FunctieKey
, dv.DienstverbandKey
, f.KostenplaatsKey
, f.KostendragerKey
, dv.IsUitbreiding
)
--SELECT * FROM Functie

,FTE_dag AS (
SELECT
d.DatumKey
,d.MaandKey
,f.FunctieKey
,f.KostendragerKey
,f.KostenplaatsKey
,FTE_Bruto						 = SUM(r.FTE_Bruto) * f.FunctiePercentage
,FTE_BAPO						 = SUM(r.FTE_BAPO) * f.FunctiePercentage
,FTE_SpaarBAPO					 = SUM(r.FTE_Spaar_BAPO) * f.FunctiePercentage
,FTE_OnbetaaldVerlof			 = COALESCE(SUM(v.FTE_OnbetaaldVerlof), 0) * f.FunctiePercentage
,IsZwangerschapsverlof			 = COALESCE(SUM(z.IsZwangerschapsverlof), 0)
,f.IsUitbreiding
,AantalDagenMaand				 = DATEPART(DAY, EOMONTH(d.Datum))
FROM [$(DWH_Quadraam)].Dim.Datum d
LEFT OUTER JOIN Rooster r ON d.DatumKey = r.DatumKey
LEFT OUTER JOIN Zwangerschapsverlof z ON d.DatumKey = z.DatumKey AND r.DienstverbandKey = z.DienstverbandKey
LEFT OUTER JOIN Onbetaaldverlof v ON d.DatumKey = v.DatumKey AND r.DienstverbandKey = v.DienstverbandKey
LEFT OUTER JOIN Functie f ON d.DatumKey = f.DatumKey AND r.DienstverbandKey = f.DienstverbandKey
WHERE
d.Datum BETWEEN DATEADD(YEAR,-5,GETDATE()) AND EOMONTH(GETDATE())
GROUP BY
d.DatumKey
,d.Datum
,d.MaandKey
,f.FunctieKey
,f.KostendragerKey
,f.KostenplaatsKey
,f.IsUitbreiding
,f.FunctiePercentage
)
--SELECT * FROM FTE_dag

,FTE_maand AS (
SELECT 
MaandKey
,FunctieKey
,KostendragerKey
,KostenplaatsKey
,FTE_Bruto							= SUM(FTE_Bruto) / MAX(AantalDagenMaand)
,FTE_BAPO							= AVG(FTE_BAPO)
,FTE_SpaarBAPO						= AVG(FTE_SpaarBAPO)
,FTE_OnbetaaldVerlof				= AVG(FTE_OnbetaaldVerlof)
,AantalDagenZwangerschapsverlof		= SUM(IsZwangerschapsverlof)
,AantalDagenMaand
,IsUitbreiding

FROM FTE_dag

GROUP BY 
MaandKey
,FunctieKey
,KostendragerKey
,KostenplaatsKey
,AantalDagenMaand
,IsUitbreiding
)
--SELECT * FROm FTE_maand

,Result AS (
SELECT
MaandKey
,fte.FunctieKey
,fte.KostendragerKey
,fte.KostenplaatsKey
, [FTE_TU]							= CASE WHEN fte.IsUitbreiding = 1 THEN fte.FTE_Bruto ELSE 0 END --conform QlikView is TU onderdeel van de FTE_Bruto
, [FTE_Bruto]						= fte.FTE_Bruto
, [FTE_BAPO]						= fte.FTE_BAPO
, [FTE_Spaar_BAPO]					= fte.FTE_SpaarBAPO
, [FTE_Detachering]					= CASE WHEN TRY_CAST(kd.KostendragerCode AS INT) = 108 THEN fte.FTE_Bruto - ((1.0 * AantalDagenZwangerschapsverlof / AantalDagenMaand) * fte.FTE_Bruto) ELSE 0 END
, [FTE_Spaarverlof]					= CASE WHEN TRY_CAST(kd.KostendragerCode AS INT) = 105 THEN fte.FTE_Bruto - ((1.0 * AantalDagenZwangerschapsverlof / AantalDagenMaand) * fte.FTE_Bruto) ELSE 0 END
, [FTE_Ouderschapsverlof]			= CASE WHEN TRY_CAST(kd.KostendragerCode AS INT) = 104 THEN fte.FTE_Bruto - ((1.0 * AantalDagenZwangerschapsverlof / AantalDagenMaand) * fte.FTE_Bruto) ELSE 0 END
, [FTE_Zwangerschapsverlof]			= (1.0 * AantalDagenZwangerschapsverlof / AantalDagenMaand) * fte.FTE_Bruto
, [FTE_Onbetaald_Verlof]			= fte.FTE_OnbetaaldVerlof

FROM FTE_maand fte
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostendrager kd ON kd.KostendragerKey = fte.KostendragerKey
)
--SELECT * FROM Result

INSERT INTO [$(DWH_Quadraam)].Fact.FTE
(
	[MaandKey]                   			 
	, [FunctieKey]                            
	, [FTE_TU]                     
	, [FTE_Bruto]                  
	, [FTE_BAPO]                   
	, [FTE_Spaar_BAPO]             
	, [FTE_Detachering]            
	, [FTE_Spaarverlof]            
	, [FTE_Ouderschapsverlof]      
	, [FTE_Zwangerschapsverlof]    
	, [FTE_Onbetaald_Verlof]       
	, [FTE_Netto]                              
)

SELECT
	r.MaandKey                 	  
	, [FunctieKey]				 		 
	, [FTE_TU]                     
	, [FTE_Bruto]                  
	, [FTE_BAPO]                   
	, [FTE_Spaar_BAPO]             
	, [FTE_Detachering]            
	, [FTE_Spaarverlof]            
	, [FTE_Ouderschapsverlof]      
	, [FTE_Zwangerschapsverlof]    
	, [FTE_Onbetaald_Verlof]       
	, [FTE_Netto]				 = [FTE_Bruto] - ([FTE_BAPO] + [FTE_Spaar_BAPO] + [FTE_Detachering] + [FTE_Spaarverlof] + [FTE_Ouderschapsverlof] + [FTE_Zwangerschapsverlof]+ [FTE_Onbetaald_Verlof])
FROM Result r

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