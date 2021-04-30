CREATE TABLE [History].[kennisitemdeluxe] (
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [tekst]          NVARCHAR (40)    NULL,
    [parentid]       UNIQUEIDENTIFIER NULL,
    [type]           INT              NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

