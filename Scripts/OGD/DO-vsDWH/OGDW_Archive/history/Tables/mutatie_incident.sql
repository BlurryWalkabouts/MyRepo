CREATE TABLE [history].[mutatie_incident] (
    [mut_afhandelingstatusid] VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [parentid]                VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]               VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [datwijzig]               DATETIME2 (7) NULL,
    [mut_datumafspraak]       DATETIME2 (7) NULL,
    [mut_datumgereed]         DATETIME2 (7) NULL,
    [mut_datumafgemeld]       DATETIME2 (7) NULL,
    [mut_operatorid]          VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_operatorgroupid]     VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_onholddatum]         DATETIME2 (7) NULL,
    [mut_priorityid]          VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_supplierid]          VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]                    VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]              INT           NOT NULL,
    [SourceDatabaseKey]       INT           NOT NULL,
    [ValidFrom]               DATETIME2 (0) NOT NULL,
    [ValidTo]                 DATETIME2 (0) NOT NULL
);

