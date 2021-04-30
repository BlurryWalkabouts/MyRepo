CREATE TABLE [History].[lift4_report_configuration_permission] (
    [unid]                   UNIQUEIDENTIFIER NOT NULL,
    [userroleid]             UNIQUEIDENTIFIER NULL,
    [report_configurationid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]         INT              NULL,
    [ValidFrom]              DATETIME2 (0)    NOT NULL,
    [ValidTo]                DATETIME2 (0)    NOT NULL
);

