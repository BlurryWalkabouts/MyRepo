CREATE TABLE [History].[sollicitatie_aanleiding] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [tekst]          NVARCHAR (25)    NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

