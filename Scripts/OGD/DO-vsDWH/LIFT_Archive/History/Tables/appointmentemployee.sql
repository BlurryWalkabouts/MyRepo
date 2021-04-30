CREATE TABLE [History].[appointmentemployee] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
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
    [employeeid]         UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);

