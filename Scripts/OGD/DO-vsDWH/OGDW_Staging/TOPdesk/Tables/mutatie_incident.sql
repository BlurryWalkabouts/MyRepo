CREATE TABLE [TOPdesk].[mutatie_incident] (
    [mut_afhandelingstatusid] VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [parentid]                VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]               VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]                    VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [datwijzig]               DATETIME     NULL,
    [mut_datumafspraak]       DATETIME     NULL,
    [mut_datumgereed]         DATETIME     NULL,
    [mut_datumafgemeld]       DATETIME     NULL,
    [mut_operatorid]          VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_operatorgroupid]     VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_onholddatum]         DATETIME     NULL,
    [mut_priorityid]          VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_supplierid]          VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]              INT          NOT NULL,
    [SourceDatabaseKey]       INT          NULL
);

