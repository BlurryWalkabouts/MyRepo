CREATE TABLE [Lift313].[invoiced_purchase] (
    [unid]           UNIQUEIDENTIFIER NULL,
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
    [AuditDWKey]     INT              NULL
);

