CREATE TABLE [dbo].[projectgroep] (
    [unid]             UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]         DATETIME                                           NULL,
    [datwijzig]        DATETIME                                           NULL,
    [uidaanmk]         UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]        UNIQUEIDENTIFIER                                   NULL,
    [status]           INT                                                NULL,
    [klantid]          UNIQUEIDENTIFIER                                   NULL,
    [naam]             NVARCHAR (70)                                      NULL,
    [projectleiderid]  UNIQUEIDENTIFIER                                   NULL,
    [contactid]        UNIQUEIDENTIFIER                                   NULL,
    [projectgroepnr]   NVARCHAR (11)                                      NULL,
    [aanvraaggroepnr]  NVARCHAR (11)                                      NULL,
    [aanvraag_vnr]     INT                                                NULL,
    [project_vnr]      INT                                                NULL,
    [percentagegereed] INT                                                NULL,
    [veranderingen]    NVARCHAR (MAX)                                     NULL,
    [AuditDWKey]   INT                                                NULL,
    [ValidFrom]        DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboprojectgroepSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]          DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboprojectgroepSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboprojectgroep ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[projectgroep], DATA_CONSISTENCY_CHECK=ON));

