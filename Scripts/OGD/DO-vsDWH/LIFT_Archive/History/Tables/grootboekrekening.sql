CREATE TABLE [History].[grootboekrekening] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [tekst]          NVARCHAR (10)    NULL,
    [omschrijving]   NVARCHAR (30)    NULL,
    [kostendrager]   NVARCHAR (25)    NULL,
    [kostenplaats]   NVARCHAR (25)    NULL,
    [type]           INT              NULL,
    [belast]         BIT              NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

