CREATE TABLE [Dim].[Service]
(
	[ServiceKey]        INT           IDENTITY (60000000, 1) NOT FOR REPLICATION,
	[ProductNomination] NVARCHAR (30) NULL
	CONSTRAINT [PK_Service] PRIMARY KEY CLUSTERED (ServiceKey)
)