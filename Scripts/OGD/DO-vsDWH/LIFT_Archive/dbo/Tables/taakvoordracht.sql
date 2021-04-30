CREATE TABLE [dbo].[taakvoordracht] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]       DATETIME                                           NULL,
    [datwijzig]      DATETIME                                           NULL,
    [uidaanmk]       UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]      UNIQUEIDENTIFIER                                   NULL,
    [status]         INT                                                NULL,
    [taakid]         UNIQUEIDENTIFIER                                   NULL,
    [type]           INT                                                NULL,
    [startdatum]     DATETIME                                           NULL,
    [einddatum]      DATETIME                                           NULL,
    [inkoopprijs]    MONEY                                              NULL,
    [werklast]       INT                                                NULL,
    [budget]         INT                                                NULL,
    [vrijvelda]      NVARCHAR (40)                                      NULL,
    [afkorting]      NVARCHAR (10)                                      NULL,
    [employeeid]     UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbotaakvoordrachtSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbotaakvoordrachtSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbotaakvoordracht ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[taakvoordracht], DATA_CONSISTENCY_CHECK=ON));

