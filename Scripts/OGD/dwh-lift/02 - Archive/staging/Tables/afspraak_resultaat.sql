CREATE TABLE [Staging].[afspraak_resultaat] (
    [unid]       UNIQUEIDENTIFIER NULL,
    [archief]    INT              NULL,
    [rang]       INT              NULL,
    [tekst]      NVARCHAR (25)    NULL,
    [afkorting]  NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL
);
