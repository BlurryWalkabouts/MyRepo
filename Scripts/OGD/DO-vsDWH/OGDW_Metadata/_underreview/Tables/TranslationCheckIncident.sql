CREATE TABLE [monitoring].[TranslationCheckIncident]
(
	[SourceDatabaseKey]      INT            NULL,
	[CustomerName]           NVARCHAR (60)  NULL,
	[CustomerAbbreviation]   NVARCHAR (100) NULL,
	[CustomerAbbreviationTT] INT            NOT NULL,
	[EntryType]              NVARCHAR (50)  NULL,
	[EntryTypeSTD]           NVARCHAR (100) NULL,
	[EntryTypeSTDTT]         INT            NOT NULL,
	[Priority]               NVARCHAR (50)  NULL,
	[PrioritySTD]            NVARCHAR (100) NULL,
	[PrioritySTDTT]          INT            NOT NULL,
	[Status]                 NVARCHAR (50)  NULL,
	[StatusSTD]              NVARCHAR (100) NULL,
	[StatusSTDTT]            INT            NOT NULL,
	[IncidentType]           NVARCHAR (50)  NULL,
	[IncidentTypeSTD]        NVARCHAR (100) NULL,
	[IncidentTypeSTDTT]      INT            NOT NULL
)