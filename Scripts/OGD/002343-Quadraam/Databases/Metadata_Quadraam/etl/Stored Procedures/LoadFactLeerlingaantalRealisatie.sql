CREATE PROCEDURE [etl].[LoadFactLeerlingaantalRealisatie]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.LeerlingaantalRealisatie

SET XACT_ABORT ON

;WITH Aantallen AS (
SELECT 
kp.[KostenplaatsKey]
,[Jaar]						= Jaar
,[Leerjaar]					= Leerjaar
,VSO_Opname					= [Aantal lln VSO opname]	  
,VSO_Verwijzing				= [Aantal lln VSO verwijzing]
,LWOO						= [Aantal lln LWOO indicatie]
,PRO						= [Aantal lln PRO indicatie]
,Instroom					= [Instroom]
,Totaal						= [Totaal aantal leerlingen]
FROM [$(Staging_Quadraam)].[SharePoint].[Leerlingaantallen] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsCode = l.Kostenplaats

UNION

SELECT 
kp.[KostenplaatsKey]
,[Jaar]						= [JaarInschrijvingKey]
,[Leerjaar]					= Leerjaar
,VSO_Opname					= COUNT(DISTINCT [LeerlingId])
,VSO_Verwijzing				= NULL
,LWOO						= NULL
,PRO						= NULL
,Instroom					= NULL
,Totaal						= NULL
FROM [$(DWH_Quadraam)].[Fact].[LeerlingBevordering] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsKey = l.KostenplaatsKey
WHERE [Meetellen] = 1 AND [VSO_type] = 'Opname'
GROUP BY kp.KostenplaatsKey, [JaarInschrijvingKey], Leerjaar

UNION

SELECT 
kp.[KostenplaatsKey]
,[Jaar]						= [JaarInschrijvingKey]
,[Leerjaar]					= Leerjaar
,VSO_Opname					= NULL
,VSO_Verwijzing				= COUNT(DISTINCT [LeerlingId])
,LWOO						= NULL
,PRO						= NULL
,Instroom					= NULL
,Totaal						= NULL
FROM [$(DWH_Quadraam)].[Fact].[LeerlingBevordering] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsKey = l.KostenplaatsKey
WHERE [Meetellen] = 1 AND [VSO_type] = 'Verwijzing'
GROUP BY kp.KostenplaatsKey, [JaarInschrijvingKey], Leerjaar

UNION

SELECT 
kp.[KostenplaatsKey]
,[Jaar]						= YEAR([Uitschrijfdatum])
,[Leerjaar]					= Leerjaar
,VSO_Opname					= NULL
,VSO_Verwijzing				= NULL
,LWOO						= NULL
,PRO						= NULL
,Instroom					= NULL
,Totaal						= COUNT(DISTINCT [LeerlingId])
FROM [$(DWH_Quadraam)].[Fact].[LeerlingBevordering] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsKey = l.KostenplaatsKey
WHERE [Meetellen] = 1
GROUP BY kp.KostenplaatsKey, YEAR([Uitschrijfdatum]), Leerjaar

UNION

SELECT 
kp.[KostenplaatsKey]
,[Jaar]						= [JaarInschrijvingKey]
,[Leerjaar]					= [Leerjaar]
,VSO_Opname					= NULL
,VSO_Verwijzing				= NULL
,LWOO						= NULL
,PRO						= NULL
,Instroom					= COUNT(DISTINCT [LeerlingId])
,Totaal						= NULL
FROM [$(DWH_Quadraam)].[Fact].[LeerlingBevordering] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsKey = l.KostenplaatsKey
WHERE [Meetellen] = 1
GROUP BY kp.KostenplaatsKey, [JaarInschrijvingKey], [Leerjaar]

UNION

SELECT 
kp.[KostenplaatsKey]
,[Jaar]						= [JaarInschrijvingKey]
,[Leerjaar]					= Leerjaar
,VSO_Opname					= NULL
,VSO_Verwijzing				= NULL
,LWOO						= COUNT(DISTINCT [LeerlingId])
,PRO						= NULL
,Instroom					= NULL
,Totaal						= NULL
FROM [$(DWH_Quadraam)].[Fact].[LeerlingBevordering] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsKey = l.KostenplaatsKey
WHERE [Meetellen] = 1 AND [IsLWOOindicatie] = 1
GROUP BY kp.KostenplaatsKey, [JaarInschrijvingKey], Leerjaar

UNION

SELECT 
kp.[KostenplaatsKey]
,[Jaar]						= [JaarInschrijvingKey]
,[Leerjaar]					= Leerjaar
,VSO_Opname					= NULL
,VSO_Verwijzing				= NULL
,LWOO						= NULL
,PRO						= COUNT(DISTINCT [LeerlingId])
,Instroom					= NULL
,Totaal						= NULL

FROM [$(DWH_Quadraam)].[Fact].[LeerlingBevordering] l
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON kp.KostenplaatsKey = l.KostenplaatsKey
WHERE [Meetellen] = 1 AND [IsPROindicatie] = 1
GROUP BY kp.KostenplaatsKey, [JaarInschrijvingKey], Leerjaar
)

INSERT INTO
	[$(DWH_Quadraam)].Fact.LeerlingaantalRealisatie
	(
	[KostenplaatsKey] 
	, [JaarKey]         
	, [Leerjaar]        
	, [Leerjaargroep]   
	, [VSO_Opname]      
	, [VSO_Verwijzing]  
	, [LWOO]            
	, [PRO]             
	, [Instroom]        
	, [Totaal]          		
	)

SELECT
	[KostenplaatsKey]
	, JaarKey				= [Jaar]				
	, [Leerjaar]			= Leerjaar
	, Leerjaargroep			= CASE WHEN COALESCE([Leerjaar], 0) = 1 THEN '1' WHEN COALESCE([Leerjaar], 0) = 0 THEN '0' ELSE '2-6' END	
	, VSO_Opname			= COALESCE(SUM(VSO_Opname), 0)
	, VSO_Verwijzing		= COALESCE(SUM(VSO_Verwijzing), 0)
	, LWOO					= COALESCE(SUM(LWOO), 0)
	, PRO					= COALESCE(SUM(PRO), 0)
	, Instroom				= COALESCE(SUM(Instroom), 0)
	, Totaal				= COALESCE(SUM(Totaal), 0)
FROM Aantallen
WHERE Jaar IS NOT NULL AND Jaar <> 9999
GROUP BY [KostenplaatsKey], [Jaar], [Leerjaar]

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