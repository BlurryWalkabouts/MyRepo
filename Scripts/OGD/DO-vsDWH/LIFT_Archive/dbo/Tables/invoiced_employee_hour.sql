CREATE TABLE [dbo].[invoiced_employee_hour] (
    [unid]                   UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]               DATETIME                                           NULL,
    [datwijzig]              DATETIME                                           NULL,
    [uidaanmk]               UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]              UNIQUEIDENTIFIER                                   NULL,
    [invoiceid]              UNIQUEIDENTIFIER                                   NULL,
    [price_ex_vat]           MONEY                                              NULL,
    [amount]                 MONEY                                              NULL,
    [percentage]             MONEY                                              NULL,
    [vatid]                  UNIQUEIDENTIFIER                                   NULL,
    [employee_assignment_id] UNIQUEIDENTIFIER                                   NULL,
    [hourtype_id]            UNIQUEIDENTIFIER                                   NULL,
    [booking_date]           DATETIME                                           NULL,
    [employee_id]            UNIQUEIDENTIFIER                                   NULL,
    [job_description_id]     UNIQUEIDENTIFIER                                   NULL,
    [product_id]             UNIQUEIDENTIFIER                                   NULL,
    [hour_id]                UNIQUEIDENTIFIER                                   NULL,
    [correctedid]            UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]         INT                                                NULL,
    [ValidFrom]              DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboinvoiced_employee_hourSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboinvoiced_employee_hourSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboinvoiced_employee_hour ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[invoiced_employee_hour], DATA_CONSISTENCY_CHECK=ON));

