CREATE TABLE [History].[invoiced_invoiceplanning] (
    [unid]                UNIQUEIDENTIFIER NOT NULL,
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
    [AuditDWKey]      INT              NULL,
    [ValidFrom]           DATETIME2 (0)    NOT NULL,
    [ValidTo]             DATETIME2 (0)    NOT NULL
);

