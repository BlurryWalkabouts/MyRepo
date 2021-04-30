CREATE TABLE [History].[betalingsconditie] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [tekst]          NVARCHAR (30)    NULL,
    [exactcode]      NVARCHAR (2)     NULL,
    [conditie]       NVARCHAR (MAX)   NULL,
    [vervaltermijn]  INT              NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

