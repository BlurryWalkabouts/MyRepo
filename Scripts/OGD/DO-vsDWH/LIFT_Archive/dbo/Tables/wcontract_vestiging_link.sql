CREATE TABLE [dbo].[wcontract_vestiging_link] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [vestigingid]    UNIQUEIDENTIFIER                                   NULL,
    [wcontractid]    UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbowcontract_vestiging_linkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbowcontract_vestiging_linkSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbowcontract_vestiging_link ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[wcontract_vestiging_link], DATA_CONSISTENCY_CHECK=ON));

