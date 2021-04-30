CREATE TABLE [monitoring].[FailedFileImports]
(
	[FailedFileImportID] INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[DWDateCreated]      DATETIME       NOT NULL,
	[AuditDWKey]         INT            NOT NULL,
	[SourceDatabaseKey]  INT            NOT NULL,
	[DatabaseLabel]      VARCHAR (64)   NOT NULL,
	[SourceFileType]     VARCHAR (10)   NOT NULL,
	[ErrorMessage]       NVARCHAR (MAX) NULL,
	[ExpectedColumns]    NVARCHAR (MAX) NULL,
	CONSTRAINT [PK_FailedFileImports] PRIMARY KEY CLUSTERED ([FailedFileImportID] ASC)
)