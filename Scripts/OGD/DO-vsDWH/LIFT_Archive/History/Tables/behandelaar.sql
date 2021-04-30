CREATE TABLE [History].[behandelaar] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [gebruikerid]    UNIQUEIDENTIFIER NULL,
    [afascode]       NVARCHAR (10)    NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [signer]         NVARCHAR (30)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

