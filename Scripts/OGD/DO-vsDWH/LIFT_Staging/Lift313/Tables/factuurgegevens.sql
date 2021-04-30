CREATE TABLE [Lift313].[factuurgegevens] (
    [unid]              UNIQUEIDENTIFIER NULL,
    [dataanmk]          DATETIME         NULL,
    [datwijzig]         DATETIME         NULL,
    [uidaanmk]          UNIQUEIDENTIFIER NULL,
    [uidwijzig]         UNIQUEIDENTIFIER NULL,
    [projectid]         UNIQUEIDENTIFIER NULL,
    [periode_start]     DATETIME         NULL,
    [periode_eind]      DATETIME         NULL,
    [fpdatum]           DATETIME         NULL,
    [factuurid]         UNIQUEIDENTIFIER NULL,
    [akkoord]           BIT              NULL,
    [forceer_afdrukken] BIT              NULL,
    [AuditDWKey]    INT              NULL
);

