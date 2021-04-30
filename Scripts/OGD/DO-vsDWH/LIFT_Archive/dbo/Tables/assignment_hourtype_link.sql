CREATE TABLE [dbo].[assignment_hourtype_link] (
    [unid]              UNIQUEIDENTIFIER                                   NOT NULL,
    [assignmentid]      UNIQUEIDENTIFIER                                   NULL,
    [budget]            MONEY                                              NULL,
    [budget_categoryid] UNIQUEIDENTIFIER                                   NULL,
    [hourtypeid]        UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]    INT                                                NULL,
    [ValidFrom]         DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboassignment_hourtype_linkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]           DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboassignment_hourtype_linkSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboassignment_hourtype_link ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[assignment_hourtype_link], DATA_CONSISTENCY_CHECK=ON));

