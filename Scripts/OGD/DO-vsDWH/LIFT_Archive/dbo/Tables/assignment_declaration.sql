CREATE TABLE [dbo].[assignment_declaration] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME                                           NULL,
    [datwijzig]          DATETIME                                           NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
    [aantal]             MONEY                                              NULL,
    [datum]              DATETIME                                           NULL,
    [verwerkt_factuur]   BIT                                                NULL,
    [factuurid]          UNIQUEIDENTIFIER                                   NULL,
    [seen_by_invoice_id] UNIQUEIDENTIFIER                                   NULL,
    [aantekeningen]      NVARCHAR (MAX)                                     NULL,
    [declarationid]      UNIQUEIDENTIFIER                                   NULL,
    [assignmentid]       UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]     INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboassignment_declarationSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboassignment_declarationSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboassignment_declaration ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[assignment_declaration], DATA_CONSISTENCY_CHECK=ON));

