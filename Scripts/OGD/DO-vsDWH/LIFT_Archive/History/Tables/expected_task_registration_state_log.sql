CREATE TABLE [History].[expected_task_registration_state_log] (
    [unid]                         UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]                     DATETIME         NULL,
    [uidaanmk]                     UNIQUEIDENTIFIER NULL,
    [old_state]                    INT              NULL,
    [new_state]                    INT              NULL,
    [expected_task_registrationid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]               INT              NULL,
    [ValidFrom]                    DATETIME2 (0)    NOT NULL,
    [ValidTo]                      DATETIME2 (0)    NOT NULL
);



