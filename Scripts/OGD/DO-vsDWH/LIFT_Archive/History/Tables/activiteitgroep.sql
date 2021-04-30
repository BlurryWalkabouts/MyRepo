CREATE TABLE [History].[activiteitgroep] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [status]         INT              NULL,
    [archiefid]      UNIQUEIDENTIFIER NULL,
    [archiefdatum]   DATETIME         NULL,
    [naam]           NVARCHAR (30)    NULL,
    [uurprijs]       MONEY            NULL,
    [nultarief]      BIT              NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

