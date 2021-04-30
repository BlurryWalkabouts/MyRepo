CREATE TABLE [dbo].[gebruikersinstellingen] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [gebruikerid]    UNIQUEIDENTIFIER                                   NULL,
    [instellingnaam] NVARCHAR (24)                                      NULL,
    [instelling]     NVARCHAR (MAX)                                     NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbogebruikersinstellingenSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbogebruikersinstellingenSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbogebruikersinstellingen ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[gebruikersinstellingen], DATA_CONSISTENCY_CHECK=ON));

