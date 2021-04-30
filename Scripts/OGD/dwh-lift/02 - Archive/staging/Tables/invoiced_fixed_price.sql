CREATE TABLE [Staging].[invoiced_fixed_price] (
    [unid]           UNIQUEIDENTIFIER    NOT NULL,
    [dataanmk]       DATETIME            NULL,
    [datwijzig]      DATETIME            NULL,
    [invoiceid]      UNIQUEIDENTIFIER    NULL,
    [price_ex_vat]   MONEY               NULL,
    [vatid]          UNIQUEIDENTIFIER    NULL,
    [project_id]     UNIQUEIDENTIFIER    NULL,
    [booking_date]   DATETIME            NULL,
    [correctedid]    UNIQUEIDENTIFIER    NULL,
    [AuditDWKey]     INT                 NULL
);