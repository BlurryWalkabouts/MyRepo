CREATE TABLE [Staging].[invoiced_employee_hour] (
    [unid]                       UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]                   DATETIME         NULL,
    [datwijzig]                  DATETIME         NULL,
    [invoiceid]                  UNIQUEIDENTIFIER NULL,
    [price_ex_vat]               MONEY            NULL,
    [percentage]                 MONEY            NULL,
    [vatid]                      UNIQUEIDENTIFIER NULL,
    [employee_assignment_id]     UNIQUEIDENTIFIER NULL,
    [hourtype_id]                UNIQUEIDENTIFIER NULL,
    [booking_date]               DATETIME         NULL,
    [employee_id]                UNIQUEIDENTIFIER NULL,
    [job_description_id]         UNIQUEIDENTIFIER NULL,
    [product_id]                 UNIQUEIDENTIFIER NULL,
    [hour_id]                    UNIQUEIDENTIFIER NULL,
    [correctedid]                UNIQUEIDENTIFIER NULL,
	[seconds]                    BIGINT           NULL,
    [AuditDWKey]                 INT              NULL
);