CREATE EXTERNAL TABLE [archive].[invoice] (
    [unid]                 uniqueidentifier   NOT NULL,
    [motherprojectid]      uniqueidentifier   NULL,
    [debtorid]             uniqueidentifier   NULL,
    [start_span]           datetime2(0)       NULL,
    [end_span]             datetime2(0)       NULL,
    [document_date]        datetime2(0)       NULL,
    [price_ex_vat]         money              NULL,
    [invoicenr]	           nvarchar(20)       NULL,
    [payment_conditionid]  uniqueidentifier   NULL,
    [vat_price]            money              NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'invoice'
);
