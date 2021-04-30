CREATE TABLE [dbo].[newsitem] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]       DATETIME                                           NULL,
    [datwijzig]      DATETIME                                           NULL,
    [uidaanmk]       UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]      UNIQUEIDENTIFIER                                   NULL,
    [status]         INT                                                NULL,
    [subject]        NVARCHAR (50)                                      NULL,
    [newstype]       INT                                                NULL,
    [publish_from]   DATETIME                                           NULL,
    [publish_to]     DATETIME                                           NULL,
    [rank]           INT                                                NULL,
    [link_url]       NVARCHAR (250)                                     NULL,
    [link_title]     NVARCHAR (100)                                     NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbonewsitemSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbonewsitemSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbonewsitem ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[newsitem], DATA_CONSISTENCY_CHECK=ON));

