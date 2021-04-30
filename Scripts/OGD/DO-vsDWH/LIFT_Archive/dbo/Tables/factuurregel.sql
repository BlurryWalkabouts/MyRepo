CREATE TABLE [dbo].[factuurregel] (
    [unid]                UNIQUEIDENTIFIER                                   NOT NULL,
    [voordrachtid]        UNIQUEIDENTIFIER                                   NULL,
    [artikelvdid]         UNIQUEIDENTIFIER                                   NULL,
    [vrijproductid]       UNIQUEIDENTIFIER                                   NULL,
    [inkoopid]            UNIQUEIDENTIFIER                                   NULL,
    [projectid]           UNIQUEIDENTIFIER                                   NULL,
    [factuurid]           UNIQUEIDENTIFIER                                   NULL,
    [voordrachttype]      INT                                                NULL,
    [bedrag]              MONEY                                              NULL,
    [bijgeboekt]          MONEY                                              NULL,
    [grootboekid]         UNIQUEIDENTIFIER                                   NULL,
    [btwid]               UNIQUEIDENTIFIER                                   NULL,
    [productid]           UNIQUEIDENTIFIER                                   NULL,
    [uurlastenid]         UNIQUEIDENTIFIER                                   NULL,
    [factuurplanningid]   UNIQUEIDENTIFIER                                   NULL,
    [verwerktaccountview] INT                                                NULL,
    [AuditDWKey]      INT                                                NULL,
    [ValidFrom]           DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbofactuurregelSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]             DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbofactuurregelSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbofactuurregel ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[factuurregel], DATA_CONSISTENCY_CHECK=ON));

