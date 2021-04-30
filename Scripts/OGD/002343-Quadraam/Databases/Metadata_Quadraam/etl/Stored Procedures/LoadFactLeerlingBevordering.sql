CREATE PROCEDURE [etl].[LoadFactLeerlingBevordering]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.LeerlingBevordering

SET XACT_ABORT ON

;WITH Vestigingen AS (
SELECT DISTINCT
	BRIN = COALESCE([BRINnummer], [BRINnummer2])
	, Vestigingsnummer = CONCAT(COALESCE([BRINnummer], [BRINnummer2], ''), COALESCE([CodeNevenvestiging], [CodeNevenvestiging2], CASE WHEN COALESCE([BRINnummer], [BRINnummer2]) IS NULL THEN NULL ELSE '00' END))
	, LocatieOmschrijving = COALESCE(LocatieOmschrijving,LocatieOmschrijving2)    
	, LocatieCode = COALESCE([LocatieCode], [LocatieCode2])

FROM [$(Staging_Quadraam)].[Magister].[leerlinggegevens])

INSERT INTO
	[$(DWH_Quadraam)].Fact.LeerlingBevordering
	(
	[LeerlingId]            
	, [KostenplaatsKey]       
	, [InschrijfDatum]        
	, [Uitschrijfdatum]       
	, [VertrekDatum]          
	, [IsInstromerExtern]     
	, [IsUitstromerExtern]    
	, [IsLWOOindicatie]       
	, [IsPROindicatie]        
	, [IsZittenblijver]       
	, [Vertrekreden]          
	, [IsVSV]                 
	, [Klas]                  
	, [Leerjaar]              
	, [Studie]                
	, [Bevorderingsresultaat] 
	, [IsBevorderd]           
	, [Meetellen]             
	, [TypeVorigeSchool]      
	, [TypeBasisSchool]       
	, [TypeVervolgSchool]     
	, [ILTcode]
	, [JaarInschrijvingKey]
	, [Leerjaargroep]
	, [VSO_type]                   			
	)

SELECT 
	LeerlingId					= CAST([Stamnummer] AS INT)
	, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
	, InschrijfDatum			= CASE WHEN [DatumEersteAanmelding] = '18991230' THEN '19000101' ELSE [DatumEersteAanmelding] END
	, Uitschrijfdatum			= CASE WHEN [Einddatum] = '18991230' THEN '99991231' ELSE [Einddatum] END
	, VertrekDatum				= CASE WHEN [Vertrekdatum] = '18991230' THEN '99991231' ELSE [Vertrekdatum] END
	, IsInstromerExtern			= COALESCE([ExterneInstromer], 0)  
	, IsUitstromerExtern		= COALESCE([ExterneUitstromer], 0)
	, IsLWOOindicatie			= COALESCE([LWOO_indicatie], 0)
	, IsPROindicatie			= COALESCE([PRO_indicatie], 0)
	, IsZittenblijver			= COALESCE([Zittenblijver], 0)
	, Vertrekreden				= COALESCE([Vertrekreden], [Vertrekreden2], '')
	, IsVSV						= COALESCE([VertrekredenVSV], 0)
	, Klas						= COALESCE([Klas], '')
	, Leerjaar					= COALESCE([Leerjaar], 0)
	, Studie					= COALESCE([Studie], '')
	, Bevorderingsresultaat		= COALESCE([Bevorderingsresultaat], '')
	, IsBevorderd				= COALESCE(BehaaldBevorderingsresultaat, 0)
	, Meetellen			  		= CASE WHEN [NietMeetellenMetOfficieleTellingen] = 0 THEN 1 ELSE 0 END
	, TypeVorigeSchool			= COALESCE([TypeVorigeschool], '')
	, TypeBasisSchool			= COALESCE([TypeBasisschool], '')
	, TypeVervolgSchool			= COALESCE(TypeVervolgschool, '')
	, ILTcode					= COALESCE([BerekendeIltCode], -1)
	, [JaarInschrijvingKey]		= CASE WHEN YEAR(CASE WHEN [Einddatum] = '18991230' THEN '99991231' ELSE [Einddatum] END) - YEAR(CASE WHEN [DatumEersteAanmelding] = '18991230' THEN '19000101' ELSE [DatumEersteAanmelding] END) <> 1 THEN NULL
								  ELSE YEAR(CASE WHEN [DatumEersteAanmelding] = '18991230' THEN '19000101' ELSE [DatumEersteAanmelding] END) END
	, [Leerjaargroep]			= CASE WHEN COALESCE([Leerjaar], 0) = 1 THEN '1' WHEN COALESCE([Leerjaar], 0) = 0 THEN '0' ELSE '2-6' END
	, VSO_type					= CASE  WHEN  (COALESCE([TypeVorigeschool], '') IN('SO','SBO','Speciaal Basis Onderwijs', 'Basisschool speciaal onderwij', 'Speciaal Onderwijs', 'Voortgezet Speciaal Onderwijs', 'SO/SVO-ZMOK')
											OR COALESCE([TypeBasisschool], '') IN('SO','SBO','Speciaal Basis Onderwijs', 'Basisschool speciaal onderwij', 'Speciaal Onderwijs', 'Voortgezet Speciaal Onderwijs', 'SO/SVO-ZMOK')
											OR COALESCE(TypeVervolgschool, '') IN('SO','SBO','Speciaal Basis Onderwijs', 'Basisschool speciaal onderwij', 'Speciaal Onderwijs', 'Voortgezet Speciaal Onderwijs', 'SO/SVO-ZMOK'))
											THEN 
												CASE WHEN COALESCE([ExterneInstromer], 0)  = 1 THEN 'Opname' WHEN COALESCE([ExterneUitstromer], 0) = 1 THEN 'Verwijzing' ELSE NULL END
										ELSE NULL END

FROM [$(Staging_Quadraam)].[Magister].[leerlinggegevens] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.VestigingsNummer = CONCAT(COALESCE([BRINnummer], [BRINnummer2], ''), COALESCE([CodeNevenvestiging], [CodeNevenvestiging2], '00'))

WHERE [DatumEersteAanmelding] > '20111231'
ORDER BY LeerlingId, Leerjaar

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Fact.LeerlingBevordering OFF
END CATCH
RETURN 0
END