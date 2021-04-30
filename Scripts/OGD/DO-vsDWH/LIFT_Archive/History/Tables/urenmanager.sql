CREATE TABLE [History].[urenmanager] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [gebruikerid]    UNIQUEIDENTIFIER NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

