CREATE TABLE [dbo].[emailemployee_selection_assessment] (
    [unid]                            UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]                        DATETIME                                           NULL,
    [datwijzig]                       DATETIME                                           NULL,
    [uidaanmk]                        UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]                       UNIQUEIDENTIFIER                                   NULL,
    [emailid]                         UNIQUEIDENTIFIER                                   NULL,
    [verzenddatum]                    DATETIME                                           NULL,
    [employee_selection_assessmentid] UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]                  INT                                                NULL,
    [ValidFrom]                       DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboemailemployee_selection_assessmentSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                         DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboemailemployee_selection_assessmentSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboemailemployee_selection_assessment ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[emailemployee_selection_assessment], DATA_CONSISTENCY_CHECK=ON));

