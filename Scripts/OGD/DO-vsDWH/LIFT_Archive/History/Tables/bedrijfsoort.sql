CREATE TABLE [History].[bedrijfsoort] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [tekst]          NVARCHAR (40)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

