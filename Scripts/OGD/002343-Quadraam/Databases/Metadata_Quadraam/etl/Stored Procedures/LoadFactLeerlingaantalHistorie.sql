CREATE PROCEDURE [etl].[LoadFactLeerlingaantalHistorie]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.LeerlingaantalHistorie;

SET XACT_ABORT ON

DROP TABLE IF EXISTS #temp;
SELECT 
	 [Afdeling]
	 , [BrinNummer]
	 , [Elementcode]
	 , [InstellingsnaamVestiging]		 
	 , [LeerOfVerblijfsjaar1Man]		= CAST([LeerOfVerblijfsjaar1Man]	 AS INT)
	 , [LeerOfVerblijfsjaar1Vrouw]		= CAST([LeerOfVerblijfsjaar1Vrouw] AS INT)
	 , [LeerOfVerblijfsjaar2Man]		= CAST([LeerOfVerblijfsjaar2Man]	 AS INT)
	 , [LeerOfVerblijfsjaar2Vrouw]		= CAST([LeerOfVerblijfsjaar2Vrouw] AS INT)
	 , [LeerOfVerblijfsjaar3Man]		= CAST([LeerOfVerblijfsjaar3Man]	 AS INT)
	 , [LeerOfVerblijfsjaar3Vrouw]		= CAST([LeerOfVerblijfsjaar3Vrouw] AS INT)
	 , [LeerOfVerblijfsjaar4Man]		= CAST([LeerOfVerblijfsjaar4Man]	 AS INT)
	 , [LeerOfVerblijfsjaar4Vrouw]		= CAST([LeerOfVerblijfsjaar4Vrouw] AS INT)
	 , [LeerOfVerblijfsjaar5Man]		= CAST([LeerOfVerblijfsjaar5Man]	 AS INT)
	 , [LeerOfVerblijfsjaar5Vrouw]		= CAST([LeerOfVerblijfsjaar5Vrouw] AS INT)
	 , [LeerOfVerblijfsjaar6Man]		= CAST([LeerOfVerblijfsjaar6Man]	 AS INT)
	 , [LeerOfVerblijfsjaar6Vrouw]		= CAST([LeerOfVerblijfsjaar6Vrouw] AS INT)
	 , [LwooIndicatie]
	 , [OnderwijstypeVoEnLeerOfVerblijfsjaar]
	 , [Opleidingsnaam]
	 , [PlaatsnaamVestiging]
	 , [ProvincieVestiging]
	 , [Vestigingsnummer]
	 , [VmboSector]
	 , [Jaar]
INTO #temp
FROM [$(Staging_Quadraam)].[DUO].[leerlingen_vo_per_vestiging_naar_onderwijstype]
WHERE BrinNummer IN(SELECT DISTINCT BRIN_Nummer FROM [$(DWH_Quadraam)].Dim.Kostenplaats);

INSERT INTO
	[$(DWH_Quadraam)].Fact.LeerlingaantalHistorie
	(
	[JaarKey]					
	, [KostenplaatsKey]			
	, [Afdeling]					
	, [ElementCode]						
	, [OpleidingsNaam]			
	, [IsLWOO_indicatie]			
	, [OnderwijsType]				
	, [VMBO_Sector]				
	, [leerjaar]					
	, [Geslacht]					
	, [AantalLeerlingen]							
	)

SELECT 
	 JaarKey							= COALESCE(CAST(LEFT([Jaar],4) AS INT), -1)
	 , KostenplaatsKey					= COALESCE(kp.KostenplaatsKey, -1)
	 , Afdeling							= COALESCE([Afdeling], '')
	 , ElementCode						= COALESCE(CAST([Elementcode] AS INT), -1)
	 , OpleidingsNaam					= COALESCE([Opleidingsnaam], '')
	 , IsLWOO_indicatie					= CASE WHEN [LwooIndicatie] = 'J' THEN 1 ELSE 0 END
	 , OnderwijsType					= COALESCE([OnderwijstypeVoEnLeerOfVerblijfsjaar], '')
	 , VMBO_Sector						= COALESCE([VmboSector], '')
     , Leerjaar							= COALESCE(CAST(RIGHT(LEFT(u.Verblijfsjaar, 20),1) AS INT), -1)
	 , Geslacht							= CASE WHEN RIGHT(u.Verblijfsjaar, 3) = 'Man' THEN 'M' ELSE 'V' END
	 , AantalLeerlingen					= COALESCE(u.AantalLeerlingen, 0)

FROM #temp
UNPIVOT(AantalLeerlingen FOR Verblijfsjaar IN(
	 [LeerOfVerblijfsjaar1Man]
	 , [LeerOfVerblijfsjaar1Vrouw]
	 , [LeerOfVerblijfsjaar2Man]
	 , [LeerOfVerblijfsjaar2Vrouw]
	 , [LeerOfVerblijfsjaar3Man]
	 , [LeerOfVerblijfsjaar3Vrouw]
	 , [LeerOfVerblijfsjaar4Man]
	 , [LeerOfVerblijfsjaar4Vrouw]
	 , [LeerOfVerblijfsjaar5Man]
	 , [LeerOfVerblijfsjaar5Vrouw]
	 , [LeerOfVerblijfsjaar6Man]
	 , [LeerOfVerblijfsjaar6Vrouw])) u

LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.VestigingsNummer = CONCAT(COALESCE(CAST(u.[BrinNummer] AS VARCHAR(5)), ''), CASE WHEN COALESCE(CAST(u.[Vestigingsnummer] AS INT), -1) > 9 THEN '' ELSE '0' END, COALESCE(CAST(u.[Vestigingsnummer] AS INT), -1))

ORDER BY JaarKey, BRIN_Nummer;

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	DROP TABLE IF EXISTS #temp;
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Fact.LeerlingaantalHistorie OFF
END CATCH
RETURN 0
END