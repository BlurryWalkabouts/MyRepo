CREATE TABLE [Lift313].[acquisition_goal_klant_link] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [acquisitionid]  UNIQUEIDENTIFIER NULL,
    [vendorid]       UNIQUEIDENTIFIER NULL,
    [progressid]     UNIQUEIDENTIFIER NULL,
    [klantid]        UNIQUEIDENTIFIER NULL,
    [contact_note]   NVARCHAR (MAX)   NULL,
    [AuditDWKey]     INT              NULL
);

