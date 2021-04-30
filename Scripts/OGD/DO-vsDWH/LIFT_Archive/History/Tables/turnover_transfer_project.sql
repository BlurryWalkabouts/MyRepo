CREATE TABLE [History].[turnover_transfer_project] (
    [unid]                UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]            DATETIME         NULL,
    [datwijzig]           DATETIME         NULL,
    [uidaanmk]            UNIQUEIDENTIFIER NULL,
    [uidwijzig]           UNIQUEIDENTIFIER NULL,
    [projectid]           UNIQUEIDENTIFIER NULL,
    [turnover_transferid] UNIQUEIDENTIFIER NULL,
    [amount]              MONEY            NULL,
    [AuditDWKey]      INT              NULL,
    [ValidFrom]           DATETIME2 (0)    NOT NULL,
    [ValidTo]             DATETIME2 (0)    NOT NULL
);

