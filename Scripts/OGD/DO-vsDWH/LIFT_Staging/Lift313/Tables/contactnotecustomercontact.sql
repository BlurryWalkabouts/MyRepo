CREATE TABLE [Lift313].[contactnotecustomercontact] (
    [unid]               UNIQUEIDENTIFIER NULL,
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
    [AuditDWKey]     INT              NULL
);

