CREATE TABLE [Lift313].[factuurplanning] (
    [unid]            UNIQUEIDENTIFIER NULL,
    [dataanmk]        DATETIME         NULL,
    [datwijzig]       DATETIME         NULL,
    [uidaanmk]        UNIQUEIDENTIFIER NULL,
    [uidwijzig]       UNIQUEIDENTIFIER NULL,
    [tekst]           NVARCHAR (60)    NULL,
    [bedrag]          MONEY            NULL,
    [datum]           DATETIME         NULL,
    [gefactureerd]    BIT              NULL,
    [projectid]       UNIQUEIDENTIFIER NULL,
    [afwijkend_btwid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]  INT              NULL
);

