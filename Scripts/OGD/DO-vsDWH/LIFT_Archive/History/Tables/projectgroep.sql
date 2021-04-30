CREATE TABLE [History].[projectgroep] (
    [unid]             UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]         DATETIME         NULL,
    [datwijzig]        DATETIME         NULL,
    [uidaanmk]         UNIQUEIDENTIFIER NULL,
    [uidwijzig]        UNIQUEIDENTIFIER NULL,
    [status]           INT              NULL,
    [klantid]          UNIQUEIDENTIFIER NULL,
    [naam]             NVARCHAR (70)    NULL,
    [projectleiderid]  UNIQUEIDENTIFIER NULL,
    [contactid]        UNIQUEIDENTIFIER NULL,
    [projectgroepnr]   NVARCHAR (11)    NULL,
    [aanvraaggroepnr]  NVARCHAR (11)    NULL,
    [aanvraag_vnr]     INT              NULL,
    [project_vnr]      INT              NULL,
    [percentagegereed] INT              NULL,
    [veranderingen]    NVARCHAR (MAX)   NULL,
    [AuditDWKey]   INT              NULL,
    [ValidFrom]        DATETIME2 (0)    NOT NULL,
    [ValidTo]          DATETIME2 (0)    NOT NULL
);

