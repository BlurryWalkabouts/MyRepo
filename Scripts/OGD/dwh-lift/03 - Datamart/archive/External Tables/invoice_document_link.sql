CREATE EXTERNAL TABLE [archive].[invoice_document_link] (
    [invoiceid]   uniqueidentifier  NULL,
    [documentid]  uniqueidentifier  NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'invoice_document_link'
);
