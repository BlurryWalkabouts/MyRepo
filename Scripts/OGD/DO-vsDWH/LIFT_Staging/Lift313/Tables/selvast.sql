CREATE TABLE [Lift313].[selvast] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [kaart]          NVARCHAR (40)    NULL,
    [naam]           NVARCHAR (50)    NULL,
    [istijdlk]       BIT              NULL,
    [voorwiecode]    INT              NULL,
    [groepid]        UNIQUEIDENTIFIER NULL,
    [selgroepid]     UNIQUEIDENTIFIER NULL,
    [aantekeningen]  NVARCHAR (MAX)   NULL,
    [AuditDWKey]     INT              NULL
);

