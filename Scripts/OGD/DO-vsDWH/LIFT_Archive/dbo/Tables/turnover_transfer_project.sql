CREATE TABLE [dbo].[turnover_transfer_project] (
    [unid]                UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]            DATETIME                                           NULL,
    [datwijzig]           DATETIME                                           NULL,
    [uidaanmk]            UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]           UNIQUEIDENTIFIER                                   NULL,
    [projectid]           UNIQUEIDENTIFIER                                   NULL,
    [turnover_transferid] UNIQUEIDENTIFIER                                   NULL,
    [amount]              MONEY                                              NULL,
    [AuditDWKey]      INT                                                NULL,
    [ValidFrom]           DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboturnover_transfer_projectSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]             DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboturnover_transfer_projectSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboturnover_transfer_project ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[turnover_transfer_project], DATA_CONSISTENCY_CHECK=ON));

