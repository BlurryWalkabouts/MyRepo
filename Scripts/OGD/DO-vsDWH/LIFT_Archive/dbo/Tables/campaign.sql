CREATE TABLE [dbo].[campaign] (
    [unid]                    UNIQUEIDENTIFIER                                   NOT NULL,
    [archief]                 INT                                                NULL,
    [rang]                    INT                                                NULL,
    [tekst]                   NVARCHAR (30)                                      NULL,
    [afkorting]               NVARCHAR (10)                                      NULL,
    [klant1_visible]          BIT                                                NULL,
    [klant2_visible]          BIT                                                NULL,
    [contactpersoon1_visible] BIT                                                NULL,
    [werknemer1_visible]      BIT                                                NULL,
    [werknemer2_visible]      BIT                                                NULL,
    [werknemer3_visible]      BIT                                                NULL,
    [werknemer4_visible]      BIT                                                NULL,
    [AuditDWKey]          INT                                                NULL,
    [ValidFrom]               DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbocampaignSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                 DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbocampaignSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbocampaign ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[campaign], DATA_CONSISTENCY_CHECK=ON));

