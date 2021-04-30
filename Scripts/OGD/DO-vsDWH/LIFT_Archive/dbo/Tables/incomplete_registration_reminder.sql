CREATE TABLE [dbo].[incomplete_registration_reminder] (
    [unid]                 UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]             DATETIME                                           NULL,
    [datwijzig]            DATETIME                                           NULL,
    [uidaanmk]             UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]            UNIQUEIDENTIFIER                                   NULL,
    [employeeid]           UNIQUEIDENTIFIER                                   NULL,
    [monitored_up_to_date] DATETIME                                           NULL,
    [AuditDWKey]       INT                                                NULL,
    [ValidFrom]            DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboincomplete_registration_reminderSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]              DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboincomplete_registration_reminderSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboincomplete_registration_reminder ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[incomplete_registration_reminder], DATA_CONSISTENCY_CHECK=ON));

