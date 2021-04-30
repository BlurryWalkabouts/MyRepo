CREATE TABLE [dbo].[gebruiker] (
    [dataanmk]       DATETIME                                           NULL,
    [datwijzig]      DATETIME                                           NULL,
    [email]          NVARCHAR (70)                                      NULL,
    [employeeid]     UNIQUEIDENTIFIER                                   NULL,
    [groepoms]       NVARCHAR (MAX)                                     NULL,
    [inlognaam]      NVARCHAR (70)                                      NULL,
    [is_template]    BIT                                                NULL,
    [naam]           NVARCHAR (40)                                      NULL,
    [status]         INT                                                NULL,
    [sv]             BIT                                                NULL,
    [uidaanmk]       UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]      UNIQUEIDENTIFIER                                   NULL,
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbogebruikerSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbogebruikerSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbogebruiker ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[gebruiker], DATA_CONSISTENCY_CHECK=ON));

