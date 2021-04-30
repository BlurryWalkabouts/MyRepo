CREATE TABLE [History].[winst_verliesneming] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
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
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

