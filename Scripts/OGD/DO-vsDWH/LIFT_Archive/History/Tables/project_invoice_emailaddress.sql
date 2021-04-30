CREATE TABLE [History].[project_invoice_emailaddress] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [projectid]      UNIQUEIDENTIFIER NULL,
    [addresstype]    INT              NULL,
    [name]           NVARCHAR (75)    NULL,
    [email]          NVARCHAR (75)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

