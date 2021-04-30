CREATE TABLE [History].[report_schedule] (
    [unid]                   UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]               DATETIME         NULL,
    [datwijzig]              DATETIME         NULL,
    [uidaanmk]               UNIQUEIDENTIFIER NULL,
    [uidwijzig]              UNIQUEIDENTIFIER NULL,
    [report_configurationid] UNIQUEIDENTIFIER NULL,
    [schedule]               NVARCHAR (MAX)   NULL,
    [AuditDWKey]         INT              NULL,
    [ValidFrom]              DATETIME2 (0)    NOT NULL,
    [ValidTo]                DATETIME2 (0)    NOT NULL
);

