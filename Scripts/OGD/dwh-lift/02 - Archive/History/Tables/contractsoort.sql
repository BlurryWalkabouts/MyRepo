CREATE TABLE [History].[contractsoort] (
    [unid]       UNIQUEIDENTIFIER NOT NULL,
    [archief]    INT              NULL,
    [rang]       INT              NULL,
    [tekst]      NVARCHAR (30)    NULL,
    [onbepaald]  BIT              NULL,
    [afkorting]  NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]  DATETIME2 (0)    NOT NULL,
    [ValidTo]    DATETIME2 (0)    NOT NULL
);

