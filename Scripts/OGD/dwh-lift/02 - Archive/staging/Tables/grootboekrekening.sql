CREATE TABLE [Staging].[grootboekrekening] (
    [unid]         UNIQUEIDENTIFIER NULL,
    [archief]      INT              NULL,
    [rang]         INT              NULL,
    [tekst]        NVARCHAR (10)    NULL,
    [omschrijving] NVARCHAR (30)    NULL,
    [kostendrager] NVARCHAR (25)    NULL,
    [kostenplaats] NVARCHAR (25)    NULL,
    [type]         INT              NULL,
    [belast]       BIT              NULL,
    [afkorting]    NVARCHAR (10)    NULL,
    [AuditDWKey]   INT              NULL
);
