CREATE TABLE [TOPdesk].[leverancier] (
    [naam]              NVARCHAR (255)                                     NULL,
    [datwijzig]         DATETIME2 (7)                                      NULL,
    [unid]              VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]        INT                                                NOT NULL,
    [SourceDatabaseKey] INT                                                NOT NULL,
    [ValidFrom]         DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_TOPdeskleverancierSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]           DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_TOPdeskleverancierSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_TOPdeskleverancier] PRIMARY KEY CLUSTERED ([unid] ASC, [AuditDWKey] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[history].[leverancier], DATA_CONSISTENCY_CHECK=ON));

