CREATE TABLE [History].[acquisition_goal_klant_link] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [acquisitionid]  UNIQUEIDENTIFIER NULL,
    [vendorid]       UNIQUEIDENTIFIER NULL,
    [progressid]     UNIQUEIDENTIFIER NULL,
    [klantid]        UNIQUEIDENTIFIER NULL,
    [contact_note]   NVARCHAR (MAX)   NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

