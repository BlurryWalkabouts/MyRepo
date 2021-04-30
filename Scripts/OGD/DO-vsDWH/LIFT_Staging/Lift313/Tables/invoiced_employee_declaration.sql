CREATE TABLE [Lift313].[invoiced_employee_declaration] (
    [unid]                   UNIQUEIDENTIFIER NULL,
    [dataanmk]               DATETIME         NULL,
    [datwijzig]              DATETIME         NULL,
    [uidaanmk]               UNIQUEIDENTIFIER NULL,
    [uidwijzig]              UNIQUEIDENTIFIER NULL,
    [invoiceid]              UNIQUEIDENTIFIER NULL,
    [price_ex_vat]           MONEY            NULL,
    [amount]                 MONEY            NULL,
    [vatid]                  UNIQUEIDENTIFIER NULL,
    [employee_assignment_id] UNIQUEIDENTIFIER NULL,
    [decl_type_id]           UNIQUEIDENTIFIER NULL,
    [booking_date]           DATETIME         NULL,
    [employee_id]            UNIQUEIDENTIFIER NULL,
    [job_description_id]     UNIQUEIDENTIFIER NULL,
    [product_id]             UNIQUEIDENTIFIER NULL,
    [declaration_id]         UNIQUEIDENTIFIER NULL,
    [correctedid]            UNIQUEIDENTIFIER NULL,
    [AuditDWKey]         INT              NULL
);

