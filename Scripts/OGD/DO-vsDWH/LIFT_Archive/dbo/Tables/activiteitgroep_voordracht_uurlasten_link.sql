CREATE TABLE [dbo].[activiteitgroep_voordracht_uurlasten_link] (
    [unid]                         UNIQUEIDENTIFIER                                   NOT NULL,
    [activiteitgroep_voordrachtid] UNIQUEIDENTIFIER                                   NULL,
    [uurlastenid]                  UNIQUEIDENTIFIER                                   NULL,
    [budget]                       MONEY                                              NULL,
    [budget_categoryid]            UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]               INT                                                NULL,
    [ValidFrom]                    DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboactiviteitgroep_voordracht_uurlasten_linkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                      DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboactiviteitgroep_voordracht_uurlasten_linkSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboactiviteitgroep_voordracht_uurlasten_link ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[activiteitgroep_voordracht_uurlasten_link], DATA_CONSISTENCY_CHECK=ON));

