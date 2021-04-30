CREATE TABLE [History].[contactnotecustomercontact] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]           DATETIME         NULL,
    [datwijzig]          DATETIME         NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [onderwerp]          NVARCHAR (80)    NULL,
    [contactnote_typeid] UNIQUEIDENTIFIER NULL,
    [categorieid]        UNIQUEIDENTIFIER NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER NULL,
    [gespreknotitie]     NVARCHAR (MAX)   NULL,
    [customercontactid]  UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);

