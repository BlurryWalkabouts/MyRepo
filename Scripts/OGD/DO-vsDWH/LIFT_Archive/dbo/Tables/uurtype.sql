CREATE TABLE [dbo].[uurtype] (
    [unid]                 UNIQUEIDENTIFIER                                   NOT NULL,
    [projectid]            UNIQUEIDENTIFIER                                   NULL,
    [looncomponent_urenid] UNIQUEIDENTIFIER                                   NULL,
    [procent]              MONEY                                              NULL,
    [tariefnaam]           NVARCHAR (30)                                      NULL,
    [declarabel]           BIT                                                NULL,
    [end_date]             DATETIME                                           NULL,
    [start_date]           DATETIME                                           NULL,
    [AuditDWKey]       INT                                                NULL,
    [ValidFrom]            DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbouurtypeSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]              DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbouurtypeSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbouurtype ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[uurtype], DATA_CONSISTENCY_CHECK=ON));



