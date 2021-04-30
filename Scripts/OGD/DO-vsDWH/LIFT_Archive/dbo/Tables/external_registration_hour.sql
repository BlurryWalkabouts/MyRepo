CREATE TABLE [dbo].[external_registration_hour] (
    [unid]                       UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]                   DATETIME                                           NULL,
    [datwijzig]                  DATETIME                                           NULL,
    [uidaanmk]                   UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]                  UNIQUEIDENTIFIER                                   NULL,
    [employeeid]                 UNIQUEIDENTIFIER                                   NULL,
    [external_registrationid]    UNIQUEIDENTIFIER                                   NULL,
    [hourtype_name]              NVARCHAR (30)                                      NULL,
    [hourtype_billable]          BIT                                                NULL,
    [hourtype_percent]           MONEY                                              NULL,
    [date]                       DATETIME                                           NULL,
    [seconds]                    BIGINT                                             NULL,
    [notes]                      NVARCHAR (MAX)                                     NULL,
    [assignment_hourtype_linkid] UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]             INT                                                NULL,
    [ValidFrom]                  DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboexternal_registration_hourSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                    DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboexternal_registration_hourSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboexternal_registration_hour ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[external_registration_hour], DATA_CONSISTENCY_CHECK=ON));

