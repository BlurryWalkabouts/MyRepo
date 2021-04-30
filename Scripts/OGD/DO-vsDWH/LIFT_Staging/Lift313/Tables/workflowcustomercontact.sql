CREATE TABLE [Lift313].[workflowcustomercontact] (
    [unid]               UNIQUEIDENTIFIER NULL,
    [dataanmk]           DATETIME         NULL,
    [datwijzig]          DATETIME         NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [status]             INT              NULL,
    [behandelaarid]      UNIQUEIDENTIFIER NULL,
    [doorstuurid]        UNIQUEIDENTIFIER NULL,
    [prioriteitid]       UNIQUEIDENTIFIER NULL,
    [wfcategorieid]      UNIQUEIDENTIFIER NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER NULL,
    [afspraakdatum]      DATETIME         NULL,
    [notificeer]         BIT              NULL,
    [isbewaakt]          BIT              NULL,
    [bewaaktdatum]       DATETIME         NULL,
    [wilbevestiging]     BIT              NULL,
    [customercontactid]  UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL
);

