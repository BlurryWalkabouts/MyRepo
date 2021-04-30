CREATE TABLE [Lift313].[factuur_doorschuiven] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [projectid]      UNIQUEIDENTIFIER NULL,
    [periodevan]     DATETIME         NULL,
    [periodetot]     DATETIME         NULL,
    [AuditDWKey]     INT              NULL
);

