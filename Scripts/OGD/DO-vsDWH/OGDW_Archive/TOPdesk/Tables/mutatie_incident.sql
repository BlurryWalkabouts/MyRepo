CREATE TABLE [TOPdesk].[mutatie_incident] (
    [mut_afhandelingstatusid] VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [parentid]                VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]               VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [datwijzig]               DATETIME2 (7)                                      NULL,
    [mut_datumafspraak]       DATETIME2 (7)                                      NULL,
    [mut_datumgereed]         DATETIME2 (7)                                      NULL,
    [mut_datumafgemeld]       DATETIME2 (7)                                      NULL,
    [mut_operatorid]          VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_operatorgroupid]     VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_onholddatum]         DATETIME2 (7)                                      NULL,
    [mut_priorityid]          VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [mut_supplierid]          VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]                    VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]              INT                                                NOT NULL,
    [SourceDatabaseKey]       INT                                                NOT NULL,
    [ValidFrom]               DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_TOPdeskmutatie_incidentSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                 DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_TOPdeskmutatie_incidentSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_TOPdeskmutatie_incident] PRIMARY KEY CLUSTERED ([unid] ASC, [AuditDWKey] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[history].[mutatie_incident], DATA_CONSISTENCY_CHECK=ON));

