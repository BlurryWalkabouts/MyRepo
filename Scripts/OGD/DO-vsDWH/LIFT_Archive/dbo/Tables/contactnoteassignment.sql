CREATE TABLE [dbo].[contactnoteassignment] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME                                           NULL,
    [datwijzig]          DATETIME                                           NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
    [onderwerp]          NVARCHAR (80)                                      NULL,
    [contactnote_typeid] UNIQUEIDENTIFIER                                   NULL,
    [categorieid]        UNIQUEIDENTIFIER                                   NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER                                   NULL,
    [assignmentid]       UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]     INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbocontactnoteassignmentSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbocontactnoteassignmentSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbocontactnoteassignment ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[contactnoteassignment], DATA_CONSISTENCY_CHECK=ON));

