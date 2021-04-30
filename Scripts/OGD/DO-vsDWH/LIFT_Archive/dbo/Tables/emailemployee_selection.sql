CREATE TABLE [dbo].[emailemployee_selection] (
    [unid]                 UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]             DATETIME                                           NULL,
    [datwijzig]            DATETIME                                           NULL,
    [uidaanmk]             UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]            UNIQUEIDENTIFIER                                   NULL,
    [emailid]              UNIQUEIDENTIFIER                                   NULL,
    [verzenddatum]         DATETIME                                           NULL,
    [employee_selectionid] UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]       INT                                                NULL,
    [ValidFrom]            DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboemailemployee_selectionSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]              DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboemailemployee_selectionSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboemailemployee_selection ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[emailemployee_selection], DATA_CONSISTENCY_CHECK=ON));

