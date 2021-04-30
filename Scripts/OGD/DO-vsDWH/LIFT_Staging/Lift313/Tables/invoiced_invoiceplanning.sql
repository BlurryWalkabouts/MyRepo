CREATE TABLE [Lift313].[invoiced_invoiceplanning] (
    [unid]                UNIQUEIDENTIFIER NULL,
    [dataanmk]            DATETIME         NULL,
    [datwijzig]           DATETIME         NULL,
    [uidaanmk]            UNIQUEIDENTIFIER NULL,
    [uidwijzig]           UNIQUEIDENTIFIER NULL,
    [invoiceid]           UNIQUEIDENTIFIER NULL,
    [price_ex_vat]        MONEY            NULL,
    [vatid]               UNIQUEIDENTIFIER NULL,
    [invoice_planning_id] UNIQUEIDENTIFIER NULL,
    [booking_date]        DATETIME         NULL,
    [correctedid]         UNIQUEIDENTIFIER NULL,
    [AuditDWKey]      INT              NULL
);

