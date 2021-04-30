CREATE TABLE [Lift313].[gebruiker] (
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [email]          NVARCHAR (70)    NULL,
    [employeeid]     UNIQUEIDENTIFIER NULL,
    [groepoms]       NVARCHAR (MAX)   NULL,
    [inlognaam]      NVARCHAR (70)    NULL,
    [is_template]    BIT              NULL,
    [naam]           NVARCHAR (40)    NULL,
    [status]         INT              NULL,
    [sv]             BIT              NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [unid]           UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL
);

