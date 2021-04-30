CREATE TABLE [TOPdesk].[om_activiteit] (
    [unid]              VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [afgemeld]          BIT                                                NOT NULL,
    [behandelaarid]     VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [bestedetijd]       BIGINT                                             NOT NULL,
    [datumafgemeld]     DATETIME2 (7)                                      NULL,
    [einddatumgepland]  DATETIME2 (7)                                      NOT NULL,
    [naam]              NVARCHAR (255)                                     NOT NULL,
    [overgeslagen]      BIT                                                NOT NULL,
    [reeksid]           VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [schemaid]          VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [startdatumgepland] DATETIME2 (7)                                      NOT NULL,
    [status]            INT                                                NOT NULL,
    [nummer]            NVARCHAR (255)                                     NOT NULL,
    [dataanmk]          DATETIME2 (7)                                      NULL,
    [datwijzig]         DATETIME2 (7)                                      NULL,
    [uidaanmk]          VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [operatorgroupid]   VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT                                                NOT NULL,
    [SourceDatabaseKey] INT                                                NULL,
    [ValidFrom]         DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_TOPdeskom_activiteitSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]           DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_TOPdeskom_activiteitSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_TOPdeskom_activiteit] PRIMARY KEY CLUSTERED ([unid] ASC, [AuditDWKey] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[history].[om_activiteit], DATA_CONSISTENCY_CHECK=ON));

