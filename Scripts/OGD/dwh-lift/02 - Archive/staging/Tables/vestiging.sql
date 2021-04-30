CREATE TABLE [Staging].[vestiging] (
    [unid]         UNIQUEIDENTIFIER NULL,
    [archief]      INT              NULL,
    [rang]         INT              NULL,
    [tekst]        NVARCHAR (40)    NULL,
    [bedrijfid]    UNIQUEIDENTIFIER NULL,
    [kostendrager] NVARCHAR (25)    NULL,
    [kostenplaats] NVARCHAR (25)    NULL,
    [afkorting]    NVARCHAR (10)    NULL,
    [AuditDWKey]   INT              NULL
);
