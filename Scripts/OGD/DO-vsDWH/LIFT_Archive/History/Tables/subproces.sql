CREATE TABLE [History].[subproces] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [procesid]       UNIQUEIDENTIFIER NULL,
    [tekst]          NVARCHAR (30)    NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

