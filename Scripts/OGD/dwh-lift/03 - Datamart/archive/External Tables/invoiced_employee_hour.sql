CREATE EXTERNAL TABLE [archive].[invoiced_employee_hour] (
    [invoiceid]               uniqueidentifier  NULL,
    [employee_assignment_id]  uniqueidentifier  NULL,
    [booking_date]            datetime          NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'invoiced_employee_hour'
);
