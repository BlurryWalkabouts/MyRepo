CREATE TABLE [History].[incomplete_registration_reminder] (
    [unid]                 UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]             DATETIME         NULL,
    [datwijzig]            DATETIME         NULL,
    [uidaanmk]             UNIQUEIDENTIFIER NULL,
    [uidwijzig]            UNIQUEIDENTIFIER NULL,
    [employeeid]           UNIQUEIDENTIFIER NULL,
    [monitored_up_to_date] DATETIME         NULL,
    [AuditDWKey]       INT              NULL,
    [ValidFrom]            DATETIME2 (0)    NOT NULL,
    [ValidTo]              DATETIME2 (0)    NOT NULL
);

