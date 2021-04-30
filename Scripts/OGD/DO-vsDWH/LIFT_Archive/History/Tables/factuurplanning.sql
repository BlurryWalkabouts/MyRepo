CREATE TABLE [History].[factuurplanning] (
    [unid]            UNIQUEIDENTIFIER NOT NULL,
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
    [AuditDWKey]  INT              NULL,
    [ValidFrom]       DATETIME2 (0)    NOT NULL,
    [ValidTo]         DATETIME2 (0)    NOT NULL
);

