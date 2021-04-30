CREATE TABLE [Staging].[dienst] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [budgethouderid] UNIQUEIDENTIFIER NULL,
    [grootboekid]    UNIQUEIDENTIFIER NULL,
    [btwid]          UNIQUEIDENTIFIER NULL,
    [naam]           NVARCHAR (30)    NULL,
    [omschrijving]   NVARCHAR (75)    NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey]     INT              NULL
);
