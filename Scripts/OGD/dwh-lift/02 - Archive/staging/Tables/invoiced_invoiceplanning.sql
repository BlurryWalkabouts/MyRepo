CREATE TABLE [Staging].[invoiced_invoiceplanning] (
    [unid]                   UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]               DATETIME         NULL,
    [datwijzig]              DATETIME         NULL,
    [invoiceid]              UNIQUEIDENTIFIER NULL,
    [price_ex_vat]           MONEY            NULL,
    [vatid]                  UNIQUEIDENTIFIER NULL,
    [invoice_planning_id]    UNIQUEIDENTIFIER NULL,
    [booking_date]           DATETIME         NULL,
    [correctedid]            UNIQUEIDENTIFIER NULL,
    [AuditDWKey]             INT              NULL
);