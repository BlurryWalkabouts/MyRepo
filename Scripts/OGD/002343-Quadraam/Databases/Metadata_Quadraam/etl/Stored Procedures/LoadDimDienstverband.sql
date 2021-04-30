CREATE PROCEDURE [etl].[LoadDimDienstverband]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Dienstverband

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dienstverband ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Dienstverband (DienstverbandKey, MedewerkerKey, Dienstverband	, [IsVervanging], [IsPoolVervanging], [IsUitbreiding], 
	[IsHoofddienstverband], [BegindatumContract], [EinddatumContract], [Dienstbetrekking], [VervangtMedewerkerKey], [VervangtMedewerkerNaam], [Arbeidsrelatie], [CAO], 
	[ContractType], [ContractOmschrijving], [ContractVolgnummer], [RedenEindeDienstverband], [Ketennummer], FTE_Dienstverband)
VALUES																												
	(-1, -1, 0, 0, 0, 0, 0, '1900-01-01', '9999-12-31', '', -1, '', '', '' , '', '' , 0, '', '', 0)					
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dienstverband OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Dienstverband
	(
	[MedewerkerKey]				
	, [Dienstverband]				
	, [IsVervanging]				
	, [IsPoolVervanging]			
	, [IsUitbreiding]				
	, [IsHoofddienstverband]		
	, [BegindatumContract]		
	, [EinddatumContract]			
	, [Dienstbetrekking]			
	, [VervangtMedewerkerKey]
	, [VervangtMedewerkerNaam]	
	, [Arbeidsrelatie]			
	, [CAO]						
	, [ContractType]				
	, [ContractOmschrijving]		
	, [ContractVolgnummer]				
	, [RedenEindeDienstverband]	
	, [Ketennummer]
	, FTE_Dienstverband										
	)

SELECT 
	MedewerkerKey						= COALESCE(m.MedewerkerKey, -1)
	, Dienstverband						= COALESCE(dv.[Dienstverband], 0)
	, IsVervanging						= COALESCE(dv.[Vervangingsdienstverband], 0)
	, IsPoolVervanging					= COALESCE(dv.[Poolvervanger], 0)
	, IsUitbreiding						= COALESCE(dv.[Uitbreidingsdienstverband], 0)
	, IsHoofddienstverband				= COALESCE(dv.[Dienstverband_is_hoofddienstverband], 0)
	, BegindatumContract				= CAST(dv.[Begindatum_contract] AS DATE)
	, EinddatumContract					= CAST(COALESCE(dv.[Einddatum_contract], '99991231') AS DATE)
	, Dienstbetrekking					= CASE 
											WHEN COALESCE(dv.[Dienstbetrekking], '') = 'Fulltimer' THEN 'OVERIG'
											WHEN COALESCE(dv.[Dienstbetrekking], '') = 'Parttimer' THEN 'OVERIG'
											WHEN COALESCE(dv.[Dienstbetrekking], '') = 'Stagiair' THEN 'STAG'
											WHEN COALESCE(dv.[Dienstbetrekking], '') = 'Wajong' THEN 'WAJ'
											WHEN COALESCE(dv.[Dienstbetrekking], '') = 'Directie' THEN 'DIR'
											ELSE COALESCE(dv.[Dienstbetrekking], '') END
	, VervangtMedewerkerKey				= COALESCE(vm.MedewerkerKey, -1)
	, VervangtMedewerkerNaam			= COALESCE(vm.MedewerkerNaam, '')
	, Arbeidsrelatie					= COALESCE(dv.[Aard_arbeidsrelatie], '')
	, CAO								= COALESCE(dv.[Cao], '')
	, ContractType						= COALESCE(dv.[Type_contract], '')
	, ContractOmschrijving				= COALESCE(dv.[soortmedewerker],'') + CASE WHEN dv.[soortmedewerker] IS NULL OR dv.[Reden] IS NULL THEN '' ELSE ' - ' END + COALESCE(dv.[Reden], '')
	, ContractVolgnummer				= COALESCE(dv.[Volgnummer_contract], 0)
	, RedenEindeDienstverband			= COALESCE(dv.[Reden_einde_dienstverband], '')
	, Ketennummer						= COALESCE(dv.[Ketennummer], '')
	, FTE_Dienstverband					= COALESCE(dv.Aantal_FTE, 0)

FROM [$(Staging_Quadraam)].[Afas].[DWH_HR_Dienstverbanden] dv

LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON m.MedewerkerCode = dv.Medewerker
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker vm ON vm.MedewerkerCode = dv.Vervangt

WHERE 1=1
	AND dv.Medewerker <> '99999'
	AND TRY_CAST(dv.Medewerker AS int) IS NOT NULL

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF 
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dienstverband OFF
END CATCH
RETURN 0
END