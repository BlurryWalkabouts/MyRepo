CREATE TABLE [dbo].[factuurgegevens] (
    [unid]              UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]          DATETIME                                           NULL,
    [datwijzig]         DATETIME                                           NULL,
    [uidaanmk]          UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]         UNIQUEIDENTIFIER                                   NULL,
    [projectid]         UNIQUEIDENTIFIER                                   NULL,
    [periode_start]     DATETIME                                           NULL,
    [periode_eind]      DATETIME                                           NULL,
    [fpdatum]           DATETIME                                           NULL,
    [factuurid]         UNIQUEIDENTIFIER                                   NULL,
    [akkoord]           BIT                                                NULL,
    [forceer_afdrukken] BIT                                                NULL,
    [AuditDWKey]    INT                                                NULL,
    [ValidFrom]         DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbofactuurgegevensSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]           DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbofactuurgegevensSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbofactuurgegevens ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[factuurgegevens], DATA_CONSISTENCY_CHECK=ON));

