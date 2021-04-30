CREATE PROCEDURE [etl].[LoadFactLeerlingaantalBegroot]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.LeerlingaantalBegroot

SET XACT_ABORT ON

INSERT INTO
	[$(DWH_Quadraam)].Fact.LeerlingaantalBegroot
	(
	[JaarKey]	
	, [KostenplaatsKey]			
	, [OnderwijsSoort]		
	, [AantalLeerlingen]				
	)
SELECT
	[JaarKey]				= COALESCE(j.JaarKey, -1)
	, [KostenplaatsKey]		= COALESCE(kp.KostenplaatsKey, -1)
	, [OnderwijsSoort]		= COALESCE(la.soort, '')
	, [AantalLeerlingen]	= COALESCE(la.aantal, 0)
FROM [$(Staging_Quadraam)].Capisci.Leerlingaantallen la
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsCode = la.kostenplaats
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Jaar j ON j.JaarNum = la.jaar

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Fact.LeerlingaantalBegroot OFF
END CATCH
RETURN 0
END