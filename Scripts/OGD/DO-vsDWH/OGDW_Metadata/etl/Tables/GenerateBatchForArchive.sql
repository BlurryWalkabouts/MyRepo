CREATE TABLE [etl].[GenerateBatchForArchive]
(
	[Step]              INT            IDENTITY (1, 1) NOT FOR REPLICATION,
	[Sproc]             NVARCHAR (MAX) NULL,
	[SourceDatabaseKey] INT            NULL,
	[AuditDWKey]        INT            NULL,
	CONSTRAINT [PK_GenerateBatchForArchive] PRIMARY KEY CLUSTERED ([Step] ASC)
)