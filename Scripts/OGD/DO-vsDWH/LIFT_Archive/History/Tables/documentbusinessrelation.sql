CREATE TABLE [History].[documentbusinessrelation] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]           DATETIME         NULL,
    [datwijzig]          DATETIME         NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [documentid]         UNIQUEIDENTIFIER NULL,
    [businessrelationid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);

