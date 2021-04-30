CREATE TABLE [Lift313].[betalingsconditie] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [tekst]          NVARCHAR (30)    NULL,
    [exactcode]      NVARCHAR (2)     NULL,
    [conditie]       NVARCHAR (MAX)   NULL,
    [vervaltermijn]  INT              NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey]     INT              NULL
);

