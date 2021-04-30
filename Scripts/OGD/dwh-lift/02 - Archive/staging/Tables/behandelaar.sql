CREATE TABLE [Staging].[behandelaar] (
    [unid]        UNIQUEIDENTIFIER NULL,
    [archief]     INT              NULL,
    [rang]        INT              NULL,
    [gebruikerid] UNIQUEIDENTIFIER NULL,
    [afascode]    NVARCHAR (10)    NULL,
    [afkorting]   NVARCHAR (10)    NULL,
    [signer]      NVARCHAR (30)    NULL,
    [AuditDWKey]  INT              NULL
);
