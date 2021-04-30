CREATE TABLE [setup].[CustomMetadata]
(
	[DataSource]         VARCHAR (10)  NOT NULL,
	[Connector]          VARCHAR (100) NOT NULL,
	[OriginalColumnName] VARCHAR (100) NOT NULL,
	[TableName]          VARCHAR (100) NOT NULL,
	[ColumnName]         VARCHAR (100) NOT NULL,
	[DataType]           VARCHAR (35)  NOT NULL,
	[OrdinalPosition]    INT           NOT NULL,
	CONSTRAINT [PK_CustomMetadata] PRIMARY KEY CLUSTERED ([DataSource] ASC, [Connector] ASC, [OriginalColumnName] ASC),
)