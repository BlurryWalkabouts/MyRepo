CREATE TABLE [Lift313].[dienst] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [budgethouderid] UNIQUEIDENTIFIER NULL,
    [grootboekid]    UNIQUEIDENTIFIER NULL,
    [btwid]          UNIQUEIDENTIFIER NULL,
    [naam]           NVARCHAR (30)    NULL,
    [stdopdracht]    NVARCHAR (MAX)   NULL,
    [omschrijving]   NVARCHAR (75)    NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey]     INT              NULL
);

