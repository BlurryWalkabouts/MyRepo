CREATE TABLE [log].[TableChanges]
(
	[TABLE_CATALOG] VARCHAR (64)   NOT NULL,
	[TABLE_SCHEMA]  VARCHAR (64)   NOT NULL,
	[TABLE_NAME]    VARCHAR (64)   NOT NULL,
	[PatDataSource] VARCHAR (64)   NOT NULL,
	[PatConnector]  VARCHAR (64)   NOT NULL,
	[LoadDate]      DATETIME2 (3)  NOT NULL,
	[Updated]       INT            NOT NULL,
	[Inserted]      INT            NOT NULL,
	[Deleted]       INT            NOT NULL,
	CONSTRAINT [PK_Metadata] PRIMARY KEY CLUSTERED ([TABLE_CATALOG] ASC, [TABLE_SCHEMA] ASC, [TABLE_NAME] ASC, [LoadDate] ASC) WITH (DATA_COMPRESSION = PAGE),
)