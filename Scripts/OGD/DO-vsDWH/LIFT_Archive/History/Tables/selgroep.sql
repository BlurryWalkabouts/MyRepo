CREATE TABLE [History].[selgroep] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [kaart]          NVARCHAR (40)    NULL,
    [groepnaam]      NVARCHAR (20)    NULL,
    [omschr]         NVARCHAR (50)    NULL,
    [voorwiecode]    INT              NULL,
    [groepid]        UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

