CREATE TABLE [TOPdesk].[om_schema] (
    [unid]              VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [naam]              NVARCHAR (255)                                     NOT NULL,
    [status]            INT                                                NOT NULL,
    [dataanmk]          DATETIME2 (7)                                      NULL,
    [datwijzig]         DATETIME2 (7)                                      NULL,
    [uidaanmk]          VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT                                                NOT NULL,
    [SourceDatabaseKey] INT                                                NULL,
    [ValidFrom]         DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_TOPdeskom_schemaSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]           DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_TOPdeskom_schemaSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_TOPdeskom_schema] PRIMARY KEY CLUSTERED ([unid] ASC, [AuditDWKey] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[history].[om_schema], DATA_CONSISTENCY_CHECK=ON));

