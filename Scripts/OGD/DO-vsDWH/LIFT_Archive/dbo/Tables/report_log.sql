CREATE TABLE [dbo].[report_log] (
    [unid]                   UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]               DATETIME                                           NULL,
    [datwijzig]              DATETIME                                           NULL,
    [uidaanmk]               UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]              UNIQUEIDENTIFIER                                   NULL,
    [report_configurationid] UNIQUEIDENTIFIER                                   NULL,
    [message]                NVARCHAR (MAX)                                     NULL,
    [start_time]             DATETIME                                           NULL,
    [end_time]               DATETIME                                           NULL,
    [AuditDWKey]         INT                                                NULL,
    [ValidFrom]              DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboreport_logSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboreport_logSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboreport_log ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[report_log], DATA_CONSISTENCY_CHECK=ON));

