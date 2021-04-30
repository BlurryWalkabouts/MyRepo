CREATE TABLE [dbo].[workflowemployee_seenby] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [workflowid]     UNIQUEIDENTIFIER                                   NULL,
    [gebruikerid]    UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboworkflowemployee_seenbySysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboworkflowemployee_seenbySysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboworkflowemployee_seenby ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[workflowemployee_seenby], DATA_CONSISTENCY_CHECK=ON));

