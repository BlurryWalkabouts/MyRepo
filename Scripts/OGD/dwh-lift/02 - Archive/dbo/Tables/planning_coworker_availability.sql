CREATE TABLE [dbo].[planning_coworker_availability] (
    [unid]       UNIQUEIDENTIFIER                                   NOT NULL,
    [coworkerid] UNIQUEIDENTIFIER                                   NULL,
    [startdate]  DATETIME                                           NULL,
    [amount]     INT                                                NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]  DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboplanning_coworker_availabilitySysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]    DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboplanning_coworker_availabilitySysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboplanning_coworker_availability] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[planning_coworker_availability], DATA_CONSISTENCY_CHECK=ON));

