CREATE TABLE [History].[signature_attachment_link] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [signatureid]    UNIQUEIDENTIFIER NULL,
    [attachmentid]   UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

