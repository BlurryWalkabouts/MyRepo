CREATE TABLE [Dim].[OperatorGroup]
(
	[OperatorGroupKey]  INT              IDENTITY (1,1) NOT FOR REPLICATION,
	[SourceDatabaseKey] INT              NOT NULL,
	[OperatorGroupID]   UNIQUEIDENTIFIER NULL,
	[OperatorGroup]     NVARCHAR (255)   NULL,
	[OperatorGroupSTD]  NVARCHAR (100)   NULL,
	CONSTRAINT [PK_OperatorGroup] PRIMARY KEY CLUSTERED ([OperatorGroupKey] ASC)
)