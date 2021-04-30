CREATE TABLE [dbo].[documentproject] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]       DATETIME                                           NULL,
    [datwijzig]      DATETIME                                           NULL,
    [uidaanmk]       UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]      UNIQUEIDENTIFIER                                   NULL,
    [documentid]     UNIQUEIDENTIFIER                                   NULL,
    [projectid]      UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbodocumentprojectSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbodocumentprojectSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbodocumentproject ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[documentproject], DATA_CONSISTENCY_CHECK=ON));

