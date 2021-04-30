CREATE TABLE [History].[dienst] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [budgethouderid] UNIQUEIDENTIFIER NULL,
    [grootboekid]    UNIQUEIDENTIFIER NULL,
    [btwid]          UNIQUEIDENTIFIER NULL,
    [naam]           NVARCHAR (30)    NULL,
    [omschrijving]   NVARCHAR (75)    NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [AuditDWKey]     INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

