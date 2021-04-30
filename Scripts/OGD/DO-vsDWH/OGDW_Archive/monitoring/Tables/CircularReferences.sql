CREATE TABLE [monitoring].[CircularReferences]
(
	[CircularReferenceID] INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[DWDateCreated]       DATETIME       NOT NULL,
	[AuditDWKey]          INT            NOT NULL,
	[SourceDatabaseKey]   INT            NOT NULL,
	[DatabaseLabel]       VARCHAR (64)   NOT NULL,
	[SourceFileType]      VARCHAR (10)   NOT NULL,
	[ChangeNumber]        NVARCHAR (255) NULL,
	[ActivityNumber]      NVARCHAR (255) NULL,
	[changeid]            VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
	CONSTRAINT [PK_CircularReferences] PRIMARY KEY CLUSTERED ([CircularReferenceID] ASC)
)