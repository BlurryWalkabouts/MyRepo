CREATE TABLE [History].[email] (
    [unid]             UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]         DATETIME         NULL,
    [datwijzig]        DATETIME         NULL,
    [uidaanmk]         UNIQUEIDENTIFIER NULL,
    [uidwijzig]        UNIQUEIDENTIFIER NULL,
    [email_templateid] UNIQUEIDENTIFIER NULL,
    [status]           INT              NULL,
    [subject]          NVARCHAR (250)   NULL,
    [header_from]      NVARCHAR (250)   NULL,
    [notes]            NVARCHAR (MAX)   NULL,
    [body]             NVARCHAR (MAX)   NULL,
    [draft]            INT              NULL,
    [is_imported]      BIT              NULL,
    [header_to]        NVARCHAR (MAX)   NULL,
    [header_cc]        NVARCHAR (MAX)   NULL,
    [header_bcc]       NVARCHAR (MAX)   NULL,
    [locale]           NVARCHAR (10)    NULL,
    [AuditDWKey]   INT              NULL,
    [ValidFrom]        DATETIME2 (0)    NOT NULL,
    [ValidTo]          DATETIME2 (0)    NOT NULL
);

