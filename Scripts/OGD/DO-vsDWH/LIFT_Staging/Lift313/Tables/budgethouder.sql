CREATE TABLE [Lift313].[budgethouder] (
    [unid]             UNIQUEIDENTIFIER NULL,
    [archief]          INT              NULL,
    [rang]             INT              NULL,
    [type]             INT              NULL,
    [tekst]            NVARCHAR (30)    NULL,
    [projectverplicht] BIT              NULL,
    [contractretour]   BIT              NULL,
    [kostendrager]     NVARCHAR (25)    NULL,
    [kostenplaats]     NVARCHAR (25)    NULL,
    [afkorting]        NVARCHAR (10)    NULL,
    [AuditDWKey]   INT              NULL
);

