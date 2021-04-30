CREATE TABLE [dbo].[doc_trefwoorden] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [documentid]     UNIQUEIDENTIFIER                                   NULL,
    [trefwoord]      NVARCHAR (60)                                      NULL,
    [trefwoordid]    UNIQUEIDENTIFIER                                   NULL,
    [standaard]      BIT                                                NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbodoc_trefwoordenSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbodoc_trefwoordenSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbodoc_trefwoorden ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[doc_trefwoorden], DATA_CONSISTENCY_CHECK=ON));

