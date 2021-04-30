CREATE TABLE [History].[invoiced_purchase] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [invoiceid]      UNIQUEIDENTIFIER NULL,
    [price_ex_vat]   MONEY            NULL,
    [amount]         MONEY            NULL,
    [vatid]          UNIQUEIDENTIFIER NULL,
    [purchase_id]    UNIQUEIDENTIFIER NULL,
    [booking_date]   DATETIME         NULL,
    [correctedid]    UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

