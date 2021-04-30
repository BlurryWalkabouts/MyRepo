CREATE PROCEDURE [etl].[LoadFactTevredenheid]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.Tevredenheid

SET XACT_ABORT ON

INSERT INTO
	[$(DWH_Quadraam)].Fact.Tevredenheid
	(
	JaarKey								
	, KostenplaatsKey					
	, [DoelstellingMedewerkers]			
	, [TevredenheidMedewerkers]			
	, NormMedewerkers					
	, [DoelstellingManagement]			
	, [TevredenheidManagement]			
	, [DoelstellingOOP]					
	, [TevredenheidOOP]					
	, [DoelstellingDocenten]			
	, [TevredenheidDocenten]			
	, DoelstellingOuders				
	, [TevredenheidOuders]				
	, NormOuders						
	, DoelstellingLeerlingen			
	, TevredenheidLeerlingen			
	, NormLeerlingen					                  				
	)
SELECT
	JaarKey								= COALESCE([Jaar], -1)
	, KostenplaatsKey					= COALESCE(kp.KostenplaatsKey, -1)
	, [DoelstellingMedewerkers]			= CASE WHEN [DoelstellingMedewerkers] = 0 THEN NULL ELSE [DoelstellingMedewerkers] 	END
	, [TevredenheidMedewerkers]			= CASE WHEN [TevredenheidMedewerkers] = 0 THEN NULL ELSE [TevredenheidMedewerkers]	END
	, NormMedewerkers					= CASE WHEN [NormMedewerkers]		  = 0 THEN NULL ELSE [NormMedewerkers]			END
	, [DoelstellingManagement]			= CASE WHEN [DoelstellingManagement]  = 0 THEN NULL ELSE [DoelstellingManagement]	END
	, [TevredenheidManagement]			= CASE WHEN [TevredenheidManagement]  = 0 THEN NULL ELSE [TevredenheidManagement]	END
	, [DoelstellingOOP]					= CASE WHEN [DoelstellingOOP]		  = 0 THEN NULL ELSE [DoelstellingOOP]			END
	, [TevredenheidOOP]					= CASE WHEN [TevredenheidOOP]		  = 0 THEN NULL ELSE [TevredenheidOOP]			END
	, [DoelstellingDocenten]			= CASE WHEN [DoelstellingDocenten]	  = 0 THEN NULL ELSE [DoelstellingDocenten]		END
	, [TevredenheidDocenten]			= CASE WHEN [TevredenheidDocenten]	  = 0 THEN NULL ELSE [TevredenheidDocenten]		END
	, DoelstellingOuders				= CASE WHEN [DoelstellingOuders]	  = 0 THEN NULL ELSE [DoelstellingOuders]		END
	, [TevredenheidOuders]				= CASE WHEN [TevredenheidOuders]	  = 0 THEN NULL ELSE [TevredenheidOuders]		END
	, NormOuders						= CASE WHEN [NormOuders]			  = 0 THEN NULL ELSE [NormOuders]				END
	, DoelstellingLeerlingen			= CASE WHEN [DoelstellingLeerlingen]  = 0 THEN NULL ELSE [DoelstellingLeerlingen]	END
	, TevredenheidLeerlingen			= CASE WHEN [TevredenheidLeerlingen]  = 0 THEN NULL ELSE [TevredenheidLeerlingen]	END
	, NormLeerlingen					= CASE WHEN [NormLeerlingen]		  = 0 THEN NULL ELSE [NormLeerlingen]			END
FROM [$(Staging_Quadraam)].[SharePoint].[Tevredenheid] t
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsCode = t.KostenplaatsCode
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Jaar j ON j.JaarNum = t.Jaar

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