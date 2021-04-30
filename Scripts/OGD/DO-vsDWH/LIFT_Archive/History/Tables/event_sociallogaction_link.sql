CREATE TABLE [History].[event_sociallogaction_link] (
    [actieid]        UNIQUEIDENTIFIER NULL,
    [gebeurtenisid]  UNIQUEIDENTIFIER NULL,
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

