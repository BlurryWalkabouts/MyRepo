CREATE EXTERNAL TABLE [archive].[invoiced_fixed_price] (
    [invoiceid]      uniqueidentifier  NULL,
    [booking_date]   datetime          NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'invoiced_fixed_price'
);
