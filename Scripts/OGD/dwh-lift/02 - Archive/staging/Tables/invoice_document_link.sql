CREATE TABLE [Staging].[invoice_document_link] (
    [unid]         UNIQUEIDENTIFIER NOT NULL,
    [invoiceid]    UNIQUEIDENTIFIER NULL,
    [documentid]   UNIQUEIDENTIFIER NULL,
    [AuditDWKey]   INT              NULL
);