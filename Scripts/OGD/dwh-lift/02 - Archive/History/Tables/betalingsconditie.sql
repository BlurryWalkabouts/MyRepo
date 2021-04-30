CREATE TABLE [History].[betalingsconditie] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
    [rang]               INT              NULL,
    [vervaltermijn]      INT              NULL,
    [AuditDWKey]         INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);