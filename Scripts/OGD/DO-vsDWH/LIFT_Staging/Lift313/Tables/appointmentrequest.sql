CREATE TABLE [Lift313].[appointmentrequest] (
    [unid]               UNIQUEIDENTIFIER NULL,
    [dataanmk]           DATETIME         NULL,
    [datwijzig]          DATETIME         NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [status]             INT              NULL,
    [behandelaarid]      UNIQUEIDENTIFIER NULL,
    [doorstuurid]        UNIQUEIDENTIFIER NULL,
    [budgethouderid]     UNIQUEIDENTIFIER NULL,
    [resultaatid]        UNIQUEIDENTIFIER NULL,
    [wfcategorieid]      UNIQUEIDENTIFIER NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER NULL,
    [afspraaktijd]       DATETIME         NULL,
    [onderwerp]          NVARCHAR (80)    NULL,
    [requestid]          UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL
);

