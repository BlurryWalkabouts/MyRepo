CREATE TABLE [Dim].[IncidentTypeSTD]
(
	[IncidentTypeSTDKey] INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[Name]               NVARCHAR (100) NULL,
	CONSTRAINT [PK_IncidentTypeSTD] PRIMARY KEY CLUSTERED ([IncidentTypeSTDKey] ASC)
)