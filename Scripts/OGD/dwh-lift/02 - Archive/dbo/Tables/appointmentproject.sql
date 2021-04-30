CREATE TABLE [dbo].[appointmentproject] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME                                           NULL,
    [datwijzig]          DATETIME                                           NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
    [status]             INT                                                NULL,
    [behandelaarid]      UNIQUEIDENTIFIER                                   NULL,
    [doorstuurid]        UNIQUEIDENTIFIER                                   NULL,
    [budgethouderid]     UNIQUEIDENTIFIER                                   NULL,
    [resultaatid]        UNIQUEIDENTIFIER                                   NULL,
    [resultaat]          NVARCHAR(25)                                       NULL,
    [wfcategorieid]      UNIQUEIDENTIFIER                                   NULL,
    [wfcategorie]        NVARCHAR(25)                                       NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER                                   NULL,
    [acquisition_goal]   NVARCHAR(30)                                       NULL,
    [afspraaktijd]       DATETIME                                           NULL,
    [onderwerp]          NVARCHAR (80)                                      NULL,
    [projectid]          UNIQUEIDENTIFIER                                   NULL,
    [AuditDWKey]         INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboappointmentprojectSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboappointmentprojectSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboappointmentproject] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[appointmentproject], DATA_CONSISTENCY_CHECK=ON));

