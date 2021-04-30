CREATE PROCEDURE [etl].[LoadFactToezichtsArrangement]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.ToezichtsArrangement

SET XACT_ABORT ON


;WITH arrangementen AS (
SELECT
JaarKey						= 2012
, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
, Onderwijssoort			= [onderwijssoort]
,ToezichtsArrangement	= [arrangement]
FROM [$(Staging_Quadraam)].[Inspectie].[TA_2012_VO] i2012
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON CONCAT([brin], CASE WHEN [vestnr] > 9 THEN '' ELSE '0' END, [vestnr]) = kp.VestigingsNummer
WHERE [brin] IN(SELECT BRIN_Nummer FROM [$(DWH_Quadraam)].Dim.Kostenplaats)

UNION

SELECT
JaarKey						= 2013
, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
, Onderwijssoort			= [Afdeling]
, ToezichtsArrangement	= [Arrangement]
FROM [$(Staging_Quadraam)].[Inspectie].[TA_2013_VO] i2013
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON CONCAT([Brin], CASE WHEN [Vestnr] > 9 THEN '' ELSE '0' END, [Vestnr]) = kp.VestigingsNummer
WHERE [Brin] IN(SELECT BRIN_Nummer FROM [$(DWH_Quadraam)].Dim.Kostenplaats)

UNION

SELECT
JaarKey						= 2014
, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
, Onderwijssoort			= [Afdeling]
, ToezichtsArrangement	= [Arrangement 1 april 2015]
FROM [$(Staging_Quadraam)].[Inspectie].[TA_2014_VO] i2014
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON CONCAT([Brin], CASE WHEN [Vestnr] > 9 THEN '' ELSE '0' END, [Vestnr]) = kp.VestigingsNummer
WHERE [Brin] IN(SELECT BRIN_Nummer FROM [$(DWH_Quadraam)].Dim.Kostenplaats)

UNION

SELECT
JaarKey						= 2015
, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
, Onderwijssoort			= [Onderwijssoort]
,ToezichtsArrangement	= [Arrangement 1 april 2016]
FROM [$(Staging_Quadraam)].[Inspectie].[TA_2015_VO] i2015
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON CONCAT([BRIN], CASE WHEN i2015.Vestigingsnummer > 9 THEN '' ELSE '0' END, i2015.Vestigingsnummer) = kp.VestigingsNummer
WHERE [BRIN] IN(SELECT BRIN_Nummer FROM [$(DWH_Quadraam)].Dim.Kostenplaats)

UNION

SELECT
JaarKey						= 2016
, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
, Onderwijssoort			= [Onderwijssoort]
,ToezichtsArrangement	= [Arrangement 1 april 2017]
FROM [$(Staging_Quadraam)].[Inspectie].[TA_2016_VO] i2016
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON CONCAT([Brin], i2016.Vestigingsnummer) = kp.VestigingsNummer
WHERE [Brin] IN(SELECT BRIN_Nummer FROM [$(DWH_Quadraam)].Dim.Kostenplaats)

UNION

SELECT
JaarKey						= 2017
, KostenplaatsKey			= COALESCE(kp.KostenplaatsKey, -1)
, Onderwijssoort			= OVTNaam
,ToezichtsArrangement	= ToezichtarrangementSvhO
FROM [$(Staging_Quadraam)].[Inspectie].[TA_2017_PO_SO_VO] i2017
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON CONCAT([BRIN], CASE WHEN i2017.vestiging > 9 THEN '' ELSE '0' END, i2017.vestiging) = kp.VestigingsNummer
WHERE [BRIN] IN(SELECT BRIN_Nummer FROM [$(DWH_Quadraam)].Dim.Kostenplaats)
)

INSERT INTO
	[$(DWH_Quadraam)].Fact.ToezichtsArrangement
	(
	[JaarKey]              
	, [KostenplaatsKey]      
	, [Onderwijssoort]       
	, [ToezichtsArrangement] 			
	)
SELECT
	JaarKey						
	, KostenplaatsKey			
	, Onderwijssoort = COALESCE(UPPER(setup.RemoveNonAlphaCharacters(Onderwijssoort)), '')	
	, ToezichtsArrangement = COALESCE(ToezichtsArrangement, '')
FROM arrangementen

ORDER BY JaarKey, KostenplaatsKey, Onderwijssoort

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Fact.ToezichtsArrangement OFF
END CATCH
RETURN 0
END