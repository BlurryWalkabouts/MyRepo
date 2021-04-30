CREATE TABLE [dbo].[lift4_report_configuration_permission] (
    [unid]                   UNIQUEIDENTIFIER                                   NOT NULL,
    [userroleid]             UNIQUEIDENTIFIER                                   NULL,
    [report_configurationid] UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]         INT                                                NULL,
    [ValidFrom]              DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbolift4_report_configuration_permissionSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbolift4_report_configuration_permissionSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbolift4_report_configuration_permission ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[lift4_report_configuration_permission], DATA_CONSISTENCY_CHECK=ON));

