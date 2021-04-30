CREATE TABLE [dbo].[planning_assignment] (
    [unid]         UNIQUEIDENTIFIER                                   NOT NULL,
    [assignmentid] UNIQUEIDENTIFIER                                   NULL,
    [startdate]    DATETIME                                           NULL,
	[enddate]      DATETIME                                           NULL,
    [amount]       INT                                                NULL,
    [AuditDWKey]   INT                                                NULL,
    [ValidFrom]    DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboplanning_assignmentSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]      DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboplanning_assignmentSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboplanning_assignment] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[planning_assignment], DATA_CONSISTENCY_CHECK=ON));

