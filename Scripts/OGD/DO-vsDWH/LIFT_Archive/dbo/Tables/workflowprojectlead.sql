CREATE TABLE [dbo].[workflowprojectlead] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME                                           NULL,
    [datwijzig]          DATETIME                                           NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
    [status]             INT                                                NULL,
    [behandelaarid]      UNIQUEIDENTIFIER                                   NULL,
    [doorstuurid]        UNIQUEIDENTIFIER                                   NULL,
    [prioriteitid]       UNIQUEIDENTIFIER                                   NULL,
    [wfcategorieid]      UNIQUEIDENTIFIER                                   NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER                                   NULL,
    [afspraakdatum]      DATETIME                                           NULL,
    [notificeer]         BIT                                                NULL,
    [isbewaakt]          BIT                                                NULL,
    [bewaaktdatum]       DATETIME                                           NULL,
    [onderwerp]          NVARCHAR (80)                                      NULL,
    [bericht]            NVARCHAR (MAX)                                     NULL,
    [wilbevestiging]     BIT                                                NULL,
    [projectleadid]      UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]     INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboworkflowprojectleadSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboworkflowprojectleadSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboworkflowprojectlead ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[workflowprojectlead], DATA_CONSISTENCY_CHECK=ON));

