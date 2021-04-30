CREATE TABLE [Lift313].[workflowassignment] (
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
    [assignmentid]       UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL
);

