CREATE TABLE [History].[email_template_attachment_link] (
    [unid]             UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]         DATETIME         NULL,
    [datwijzig]        DATETIME         NULL,
    [uidaanmk]         UNIQUEIDENTIFIER NULL,
    [uidwijzig]        UNIQUEIDENTIFIER NULL,
    [attachmentid]     UNIQUEIDENTIFIER NULL,
    [email_templateid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]   INT              NULL,
    [ValidFrom]        DATETIME2 (0)    NOT NULL,
    [ValidTo]          DATETIME2 (0)    NOT NULL
);

