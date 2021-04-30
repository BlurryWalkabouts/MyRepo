CREATE PROCEDURE [etl].[LoadDimBevoegdheid]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Bevoegdheid

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Bevoegdheid ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Bevoegdheid ([BevoegdheidKey], [MedewerkerKey],[BegindatumOpleiding],[EinddatumOpleiding],[ResultaatOpleiding],[HeeftDiploma],[OmschrijvingOpleiding],[OpleidingsType],[VakBevoegdheid],[Bevoegdheidsgraad])
VALUES
	(-1, -1, '19000101', '99991231','',0,'Onbekend','','','')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Bevoegdheid OFF

DELETE FROM [$(Staging_Quadraam)].Afas.DWH_HR_Opleidingen WHERE Werkgever IS NULL

INSERT INTO
	[$(DWH_Quadraam)].Dim.Bevoegdheid
	(
		[MedewerkerKey]         
		, [BegindatumOpleiding]   
		, [EinddatumOpleiding]    
		, [ResultaatOpleiding]    
		, [HeeftDiploma]          
		, [OmschrijvingOpleiding] 
		, [OpleidingsType]        
		, [VakBevoegdheid]        
		, [Bevoegdheidsgraad]     
	)
SELECT 
	MedewerkerKey					= COALESCE(m.MedewerkerKey, -1)
	, BegindatumOpleiding			= CAST([Begindatum_opleiding] AS DATE)
	, EinddatumOpleiding			= COALESCE(CAST([Einddatum_opleiding] AS DATE), '99991231')
	, ResultaatOpleiding			= COALESCE([Resultaat_opleiding], '')
	, HeeftDiploma					= CAST([Diploma] AS BIT)
	, OmschrijvingOpleiding			= COALESCE([Omschrijving_opleiding], '')
	, OpleidingsType				= COALESCE([Code_opleiding], 'Onbekend')
	, VakBevoegdheid				= COALESCE(b._DC_Vakken, '')
	, Bevoegdheidsgraad				= COALESCE(b._DC_Graad, '')
FROM [$(Staging_Quadraam)].[Afas].[DWH_HR_Opleidingen] o
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON m.MedewerkerCode = o.Medewerker
LEFT OUTER JOIN [$(Staging_Quadraam)].[Afas].[DWH_HR_Opleidingen_bevoegdheden] b ON b.Opleiding = o.Soort_opleiding

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Kostendrager OFF
END CATCH
RETURN 0
END