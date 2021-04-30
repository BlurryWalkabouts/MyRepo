CREATE TABLE [History].[bedrijf] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [tekst]          NVARCHAR (60)    NULL,
    [factuurcode]    NVARCHAR (2)     NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [twinfieldcode]  NVARCHAR (20)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

