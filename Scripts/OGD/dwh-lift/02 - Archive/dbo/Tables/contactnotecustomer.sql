CREATE TABLE [dbo].[contactnotecustomer] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME2(0)                                       NULL,
    [datwijzig]          DATETIME2(0)                                       NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
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
	[AuditDWKey]         INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbocontactnotecustomerSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbocontactnotecustomerSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbocontactnotecustomer] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[contactnotecustomer], DATA_CONSISTENCY_CHECK=ON));