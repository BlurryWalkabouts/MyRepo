CREATE TABLE [dbo].[expected_task_registration_state_log] (
    [unid]                         UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]                     DATETIME                                           NULL,
    [uidaanmk]                     UNIQUEIDENTIFIER                                   NULL,
    [old_state]                    INT                                                NULL,
    [new_state]                    INT                                                NULL,
    [expected_task_registrationid] UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]               INT                                                NULL,
    [ValidFrom]                    DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboexpected_task_registration_state_logSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                      DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboexpected_task_registration_state_logSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboexpected_task_registration_state_log ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[expected_task_registration_state_log], DATA_CONSISTENCY_CHECK=ON));

