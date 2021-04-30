CREATE TABLE [dbo].[acquisition_goal_contactpersoon_link] (
    [unid]             UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]         DATETIME                                           NULL,
    [datwijzig]        DATETIME                                           NULL,
    [uidaanmk]         UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]        UNIQUEIDENTIFIER                                   NULL,
    [acquisitionid]    UNIQUEIDENTIFIER                                   NULL,
    [vendorid]         UNIQUEIDENTIFIER                                   NULL,
    [progressid]       UNIQUEIDENTIFIER                                   NULL,
    [contactpersoonid] UNIQUEIDENTIFIER                                   NULL,
    [contact_note]     NVARCHAR (MAX)                                     NULL,
    [AuditDWKey]   INT                                                NULL,
    [ValidFrom]        DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboacquisition_goal_contactpersoon_linkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]          DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboacquisition_goal_contactpersoon_linkSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboacquisition_goal_contactpersoon_link ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[acquisition_goal_contactpersoon_link], DATA_CONSISTENCY_CHECK=ON));

