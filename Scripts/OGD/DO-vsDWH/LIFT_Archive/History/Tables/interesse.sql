CREATE TABLE [History].[interesse] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [budgethouderid] UNIQUEIDENTIFIER NULL,
    [contactid]      UNIQUEIDENTIFIER NULL,
    [faseid]         UNIQUEIDENTIFIER NULL,
    [cijferid]       UNIQUEIDENTIFIER NULL,
    [cpid]           UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

