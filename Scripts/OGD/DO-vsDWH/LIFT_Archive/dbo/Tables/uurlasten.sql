CREATE TABLE [dbo].[uurlasten] (
    [unid]                        UNIQUEIDENTIFIER                                   NOT NULL,
    [tariefnaam]                  NVARCHAR (30)                                      NULL,
    [projectid]                   UNIQUEIDENTIFIER                                   NULL,
    [looncomponent_declaratiesid] UNIQUEIDENTIFIER                                   NULL,
    [tarief]                      MONEY                                              NULL,
    [grootboekid]                 UNIQUEIDENTIFIER                                   NULL,
    [intern_tarief]               MONEY                                              NULL,
    [intern_grootboekid]          UNIQUEIDENTIFIER                                   NULL,
    [is_kilometer]                BIT                                                NULL,
    [btwid]                       UNIQUEIDENTIFIER                                   NULL,
    [end_date]                    DATETIME                                           NULL,
    [start_date]                  DATETIME                                           NULL,
    [AuditDWKey]              INT                                                NULL,
    [ValidFrom]                   DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbouurlastenSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                     DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbouurlastenSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbouurlasten ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[uurlasten], DATA_CONSISTENCY_CHECK=ON));



