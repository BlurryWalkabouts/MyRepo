CREATE TABLE [dbo].[emailproject_request] (
    [unid]              UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]          DATETIME                                           NULL,
    [datwijzig]         DATETIME                                           NULL,
    [uidaanmk]          UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]         UNIQUEIDENTIFIER                                   NULL,
    [emailid]           UNIQUEIDENTIFIER                                   NULL,
    [verzenddatum]      DATETIME                                           NULL,
    [project_requestid] UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]    INT                                                NULL,
    [ValidFrom]         DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboemailproject_requestSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]           DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboemailproject_requestSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboemailproject_request ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[emailproject_request], DATA_CONSISTENCY_CHECK=ON));

