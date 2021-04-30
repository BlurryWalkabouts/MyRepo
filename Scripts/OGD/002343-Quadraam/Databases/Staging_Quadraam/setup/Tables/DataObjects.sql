CREATE TABLE [setup].[DataObjects]
(
	[DataSource]     VARCHAR (10)   NOT NULL,
	[ContentType]    VARCHAR (10)   NOT NULL,
	[Connector]      VARCHAR (100)  NULL,
	[BulkColumn]     NVARCHAR (MAX) NULL,
	[XMLData]        XML            NULL,
	[ImportDuration] INT            NULL,
	[ImportDateTime] DATETIME2 (3)  CONSTRAINT [DF_DataObjects_ImportDateTime] DEFAULT SYSUTCDATETIME() NOT NULL,
	CONSTRAINT [PK_DataObjects] PRIMARY KEY CLUSTERED ([DataSource] ASC, [ContentType] ASC, [ImportDateTime] ASC),
)