CREATE TABLE [dbo].[taak] (
    [unid]                     UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]                 DATETIME                                           NULL,
    [datwijzig]                DATETIME                                           NULL,
    [uidaanmk]                 UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]                UNIQUEIDENTIFIER                                   NULL,
    [status]                   INT                                                NULL,
    [sprocesid]                UNIQUEIDENTIFIER                                   NULL,
    [procesid]                 UNIQUEIDENTIFIER                                   NULL,
    [taaknr]                   NVARCHAR (8)                                       NULL,
    [looncomponent_urenid]     UNIQUEIDENTIFIER                                   NULL,
    [taaknaam]                 NVARCHAR (30)                                      NULL,
    [iedereen]                 BIT                                                NULL,
    [system_task_type]         INT                                                NULL,
    [einddatum]                DATETIME                                           NULL,
    [available_for_employee]   INT                                                NULL,
    [available_for_contractor] INT                                                NULL,
    [hour_note_required]       BIT                                                NULL,
    [AuditDWKey]               INT                                                NULL,
    [ValidFrom]                DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbotaakSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                  DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbotaakSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbotaak] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[taak], DATA_CONSISTENCY_CHECK=ON));

