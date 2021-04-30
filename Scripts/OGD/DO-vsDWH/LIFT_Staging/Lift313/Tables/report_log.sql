CREATE TABLE [Lift313].[report_log] (
    [unid]                   UNIQUEIDENTIFIER NULL,
    [dataanmk]               DATETIME         NULL,
    [datwijzig]              DATETIME         NULL,
    [uidaanmk]               UNIQUEIDENTIFIER NULL,
    [uidwijzig]              UNIQUEIDENTIFIER NULL,
    [report_configurationid] UNIQUEIDENTIFIER NULL,
    [message]                NVARCHAR (MAX)   NULL,
    [start_time]             DATETIME         NULL,
    [end_time]               DATETIME         NULL,
    [AuditDWKey]         INT              NULL
);

