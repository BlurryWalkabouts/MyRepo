CREATE TABLE [dbo].[wnkennisniveau] (
    [unid]            UNIQUEIDENTIFIER                                   NOT NULL,
    [werknemerid]     UNIQUEIDENTIFIER                                   NULL,
    [itemid]          UNIQUEIDENTIFIER                                   NULL,
    [cijfer]          INT                                                NULL,
    [acijfer]         INT                                                NULL,
    [werkervaring]    MONEY                                              NULL,
    [ervaring_is_eis] BIT                                                NULL,
    [AuditDWKey]  INT                                                NULL,
    [ValidFrom]       DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbownkennisniveauSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]         DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbownkennisniveauSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbownkennisniveau ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[wnkennisniveau], DATA_CONSISTENCY_CHECK=ON));

