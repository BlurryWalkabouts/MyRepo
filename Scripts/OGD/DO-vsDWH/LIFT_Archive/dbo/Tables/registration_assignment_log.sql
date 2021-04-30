CREATE TABLE [dbo].[registration_assignment_log] (
    [unid]                UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]            DATETIME                                           NULL,
    [datwijzig]           DATETIME                                           NULL,
    [uidaanmk]            UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]           UNIQUEIDENTIFIER                                   NULL,
    [submit_date]         DATETIME                                           NULL,
    [submit_date_cleared] BIT                                                NULL,
    [accept_date]         DATETIME                                           NULL,
    [accept_date_cleared] BIT                                                NULL,
    [assignmentid]        UNIQUEIDENTIFIER                                   NULL,
    [changing_process]    INT                                                NULL,
    [AuditDWKey]      INT                                                NULL,
    [ValidFrom]           DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboregistration_assignment_logSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]             DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboregistration_assignment_logSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboregistration_assignment_log ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[registration_assignment_log], DATA_CONSISTENCY_CHECK=ON));

