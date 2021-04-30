CREATE TABLE [dbo].[contactnotecustomercontact] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME2(0)                                       NULL,
    [datwijzig]          DATETIME2(0)                                       NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
    [onderwerp]			 NVARCHAR(80)										NULL,
    [contactnote_typeid] UNIQUEIDENTIFIER									NULL,
	[customerid]         UNIQUEIDENTIFIER                                   NULL,
    [customercontactid]  UNIQUEIDENTIFIER                                   NULL,
    [conversationdate]   DATETIME2(0)                                       NULL,
    [typeid]             UNIQUEIDENTIFIER                                   NULL,
    [type]               NVARCHAR(60)                                       NULL,
    [categorieid]        UNIQUEIDENTIFIER                                   NULL,
    [categorie]          NVARCHAR(25)                                       NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER                                   NULL,
    [acquisition_goal]   NVARCHAR(30)                                       NULL,
    [gespreknotitie]	 NVARCHAR(MAX)										NULL,
	[AuditDWKey]         INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbocontactnotecustomercontactSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbocontactnotecustomercontactSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbocontactnotecustomercontact] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[contactnotecustomercontact], DATA_CONSISTENCY_CHECK=ON));

