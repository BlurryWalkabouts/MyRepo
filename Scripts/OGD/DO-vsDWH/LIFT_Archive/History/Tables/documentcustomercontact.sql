CREATE TABLE [History].[documentcustomercontact] (
    [unid]              UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]          DATETIME         NULL,
    [datwijzig]         DATETIME         NULL,
    [uidaanmk]          UNIQUEIDENTIFIER NULL,
    [uidwijzig]         UNIQUEIDENTIFIER NULL,
    [documentid]        UNIQUEIDENTIFIER NULL,
    [customercontactid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]    INT              NULL,
    [ValidFrom]         DATETIME2 (0)    NOT NULL,
    [ValidTo]           DATETIME2 (0)    NOT NULL
);

