CREATE TABLE [History].[budgethouder] (
    [unid]             UNIQUEIDENTIFIER NOT NULL,
    [archief]          INT              NULL,
    [rang]             INT              NULL,
    [type]             INT              NULL,
    [tekst]            NVARCHAR (30)    NULL,
    [projectverplicht] BIT              NULL,
    [contractretour]   BIT              NULL,
    [kostendrager]     NVARCHAR (25)    NULL,
    [kostenplaats]     NVARCHAR (25)    NULL,
    [afkorting]        NVARCHAR (10)    NULL,
    [AuditDWKey]       INT              NULL,
    [ValidFrom]        DATETIME2 (0)    NOT NULL,
    [ValidTo]          DATETIME2 (0)    NOT NULL
);

