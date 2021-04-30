CREATE TABLE [History].[appointmentcustomer] (
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
    [resultaat]          NVARCHAR(25)     NULL,
    [wfcategorieid]      UNIQUEIDENTIFIER NULL,
    [wfcategorie]        NVARCHAR(25)     NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER NULL,
    [acquisition_goal]   NVARCHAR(30)     NULL,
    [afspraaktijd]       DATETIME         NULL,
    [customerid]         UNIQUEIDENTIFIER NULL,
    [AuditDWKey]         INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);

