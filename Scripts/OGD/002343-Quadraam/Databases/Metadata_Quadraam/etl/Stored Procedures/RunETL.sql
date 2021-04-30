CREATE PROCEDURE [etl].[RunETL]
AS
BEGIN 

-- Script: RunETL
-- Nota:   Roept alle andere ETL scripts aan op volgorde van afhankelijkheid
-- Author:

DECLARE @StartTime DATETIME2 = GETDATE();

EXEC etl.DisableForeignKeys;

INSERT INTO 
  [log].ProcedureLog 
  ( 
  Batch 
  , Starttijd
  , Eindtijd
  , Script 
  , IsGeslaagd 
  , Melding 
  ) 
SELECT 
  Batch = COALESCE((SELECT MAX(COALESCE(Batch,0)) + 1 FROM [log].ProcedureLog), 1) 
  , Starttijd = @StartTime
  , Eindtijd = GETDATE() 
  , Script = 'RunETL' 
  , IsGeslaagd = 1 
  , Melding = 'Begin ETL procedure';

-- Datum-gerelateerde tabellen
EXEC etl.LoadDimDatum
EXEC etl.LoadDimMaand
EXEC etl.LoadDimJaar

-- Dimensietabellen
EXEC etl.LoadDimBevoegdheid
EXEC etl.LoadDimDagboek
EXEC etl.LoadDimGrootboek
EXEC etl.LoadDimKostenplaats
EXEC etl.LoadDimKostendrager
EXEC etl.LoadDimLooncomponent
EXEC etl.LoadDimMedewerker
EXEC etl.LoadDimScenario
EXEC etl.LoadDimTransactieType
EXEC etl.LoadDimFactuur

EXEC etl.LoadDimDienstverband -- na Medewerker
EXEC etl.LoadDimFunctieSchaal -- na Dienstverband
EXEC etl.LoadDimFunctie -- na Medewwerker, Dienstverband, Kostenplaats, Kostendrager

-- Facttabellen FIN
EXEC etl.LoadFactMutatie

-- Facttabellen HR
EXEC etl.LoadFactFormatieBegroting
EXEC etl.LoadFactFTE
EXEC etl.LoadFactVerzuim
EXEC etl.LoadFactSalarissen
EXEC etl.LoadFactWerkgeverskosten
EXEC etl.LoadFactLeerlingaantalBegroot
EXEC etl.LoadFactLeerlingaantalHistorie
EXEC etl.LoadFactLeerlingBevordering
EXEC etl.LoadFactToezichtsArrangement
EXEC etl.LoadFactTevredenheid
EXEC etl.LoadFactLeerlingaantalRealisatie

-- Afgerond
EXEC etl.EnableForeignKeys
EXEC [log].[Log] @@PROCID, @StartTime

END