CREATE TABLE [dbo].[report_schedule] (
    [unid]                   UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]               DATETIME                                           NULL,
    [datwijzig]              DATETIME                                           NULL,
    [uidaanmk]               UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]              UNIQUEIDENTIFIER                                   NULL,
    [report_configurationid] UNIQUEIDENTIFIER                                   NULL,
    [schedule]               NVARCHAR (MAX)                                     NULL,
    [AuditDWKey]         INT                                                NULL,
    [ValidFrom]              DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboreport_scheduleSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboreport_scheduleSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboreport_schedule ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[report_schedule], DATA_CONSISTENCY_CHECK=ON));

