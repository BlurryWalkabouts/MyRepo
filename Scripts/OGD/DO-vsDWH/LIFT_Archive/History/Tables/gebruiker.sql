CREATE TABLE [History].[gebruiker] (
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
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

