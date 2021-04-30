CREATE TABLE [History].[invoice_document_link] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [invoiceid]      UNIQUEIDENTIFIER NULL,
    [documentid]     UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

