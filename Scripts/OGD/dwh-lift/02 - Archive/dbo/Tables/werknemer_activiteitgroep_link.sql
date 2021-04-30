CREATE TABLE [dbo].[werknemer_activiteitgroep_link] (
    [unid]               UNIQUEIDENTIFIER  NOT NULL,
    [werknemerid]        UNIQUEIDENTIFIER  NULL,
    [activiteitgroepid]  UNIQUEIDENTIFIER  NULL,
    [AuditDWKey]         INT               NULL,
    [ValidFrom]          DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbowerknemer_activiteitgroep_linkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbowerknemer_activiteitgroep_linkSysEnd]   DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbowerknemer_activiteitgroep_link] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[werknemer_activiteitgroep_link], DATA_CONSISTENCY_CHECK=ON));
