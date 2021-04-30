CREATE TABLE [Lift313].[invoiced_employee_hour] (
    [unid]                   UNIQUEIDENTIFIER NULL,
    [dataanmk]               DATETIME         NULL,
    [datwijzig]              DATETIME         NULL,
    [uidaanmk]               UNIQUEIDENTIFIER NULL,
    [uidwijzig]              UNIQUEIDENTIFIER NULL,
    [invoiceid]              UNIQUEIDENTIFIER NULL,
    [price_ex_vat]           MONEY            NULL,
    [amount]                 MONEY            NULL,
    [percentage]             MONEY            NULL,
    [vatid]                  UNIQUEIDENTIFIER NULL,
    [employee_assignment_id] UNIQUEIDENTIFIER NULL,
    [hourtype_id]            UNIQUEIDENTIFIER NULL,
    [booking_date]           DATETIME         NULL,
    [employee_id]            UNIQUEIDENTIFIER NULL,
    [job_description_id]     UNIQUEIDENTIFIER NULL,
    [product_id]             UNIQUEIDENTIFIER NULL,
    [hour_id]                UNIQUEIDENTIFIER NULL,
    [correctedid]            UNIQUEIDENTIFIER NULL,
    [AuditDWKey]         INT              NULL
);

