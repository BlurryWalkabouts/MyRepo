CREATE TABLE [History].[contactnotecustomercontact] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]           DATETIME2(0)     NULL,
    [datwijzig]          DATETIME2(0)     NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [onderwerp]			 NVARCHAR(80)	  NULL,
    [contactnote_typeid] UNIQUEIDENTIFIER NULL,
	[customerid]         UNIQUEIDENTIFIER NULL,
    [customercontactid]  UNIQUEIDENTIFIER NULL,
    [conversationdate]   DATETIME2(0)     NULL,
    [typeid]             UNIQUEIDENTIFIER NULL,
    [type]               NVARCHAR(60)     NULL,
    [categorieid]        UNIQUEIDENTIFIER NULL,
    [categorie]          NVARCHAR(25)     NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER NULL,
    [acquisition_goal]   NVARCHAR(30)     NULL,
    [gespreknotitie]	 NVARCHAR(MAX)    NULL,
	[AuditDWKey]         INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);

