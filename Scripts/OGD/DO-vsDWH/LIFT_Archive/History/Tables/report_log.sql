CREATE TABLE [History].[report_log] (
    [unid]                   UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]               DATETIME         NULL,
    [datwijzig]              DATETIME         NULL,
    [uidaanmk]               UNIQUEIDENTIFIER NULL,
    [uidwijzig]              UNIQUEIDENTIFIER NULL,
    [report_configurationid] UNIQUEIDENTIFIER NULL,
    [message]                NVARCHAR (MAX)   NULL,
    [start_time]             DATETIME         NULL,
    [end_time]               DATETIME         NULL,
    [AuditDWKey]         INT              NULL,
    [ValidFrom]              DATETIME2 (0)    NOT NULL,
    [ValidTo]                DATETIME2 (0)    NOT NULL
);

