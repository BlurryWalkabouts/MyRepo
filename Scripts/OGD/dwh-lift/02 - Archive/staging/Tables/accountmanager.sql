CREATE TABLE [Staging].[accountmanager] (
    [unid]        UNIQUEIDENTIFIER NULL,
    [archief]     INT              NULL,
    [rang]        INT              NULL,
    [gebruikerid] UNIQUEIDENTIFIER NULL,
    [afkorting]   NVARCHAR (10)    NULL,
    [signer]      NVARCHAR (30)    NULL,
    [AuditDWKey]  INT              NULL
);

