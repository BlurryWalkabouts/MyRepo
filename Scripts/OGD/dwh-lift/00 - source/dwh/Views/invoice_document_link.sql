CREATE VIEW dwh.[invoice_document_link] AS
SELECT
    [unid],
    [invoiceid],
    [documentid]
FROM dbo.[invoice_document_link];