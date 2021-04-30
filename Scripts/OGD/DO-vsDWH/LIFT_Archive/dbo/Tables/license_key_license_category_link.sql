CREATE TABLE [dbo].[license_key_license_category_link] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME                                           NULL,
    [datwijzig]          DATETIME                                           NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
    [license_key]        INT                                                NULL,
    [license_categoryid] UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]     INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbolicense_key_license_category_linkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbolicense_key_license_category_linkSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbolicense_key_license_category_link ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[license_key_license_category_link], DATA_CONSISTENCY_CHECK=ON));

