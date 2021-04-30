CREATE TABLE [dbo].[invoiced_purchase] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]       DATETIME                                           NULL,
    [datwijzig]      DATETIME                                           NULL,
    [uidaanmk]       UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]      UNIQUEIDENTIFIER                                   NULL,
    [invoiceid]      UNIQUEIDENTIFIER                                   NULL,
    [price_ex_vat]   MONEY                                              NULL,
    [amount]         MONEY                                              NULL,
    [vatid]          UNIQUEIDENTIFIER                                   NULL,
    [purchase_id]    UNIQUEIDENTIFIER                                   NULL,
    [booking_date]   DATETIME                                           NULL,
    [correctedid]    UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboinvoiced_purchaseSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboinvoiced_purchaseSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboinvoiced_purchase ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[invoiced_purchase], DATA_CONSISTENCY_CHECK=ON));

