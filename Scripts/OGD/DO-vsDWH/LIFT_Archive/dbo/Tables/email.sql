CREATE TABLE [dbo].[email] (
    [unid]             UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]         DATETIME                                           NULL,
    [datwijzig]        DATETIME                                           NULL,
    [uidaanmk]         UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]        UNIQUEIDENTIFIER                                   NULL,
    [email_templateid] UNIQUEIDENTIFIER                                   NULL,
    [status]           INT                                                NULL,
    [subject]          NVARCHAR (250)                                     NULL,
    [header_from]      NVARCHAR (250)                                     NULL,
    [notes]            NVARCHAR (MAX)                                     NULL,
    [body]             NVARCHAR (MAX)                                     NULL,
    [draft]            INT                                                NULL,
    [is_imported]      BIT                                                NULL,
    [header_to]        NVARCHAR (MAX)                                     NULL,
    [header_cc]        NVARCHAR (MAX)                                     NULL,
    [header_bcc]       NVARCHAR (MAX)                                     NULL,
    [locale]           NVARCHAR (10)                                      NULL,
    [AuditDWKey]   INT                                                NULL,
    [ValidFrom]        DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboemailSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]          DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboemailSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboemail ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[email], DATA_CONSISTENCY_CHECK=ON));

