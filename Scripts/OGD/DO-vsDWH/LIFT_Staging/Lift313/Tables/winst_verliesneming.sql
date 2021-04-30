CREATE TABLE [Lift313].[winst_verliesneming] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [status]         INT              NULL,
    [projectid]      UNIQUEIDENTIFIER NULL,
    [bedrag]         MONEY            NULL,
    [datum]          DATETIME         NULL,
    [note]           NVARCHAR (60)    NULL,
    [grootboekid]    UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL
);

