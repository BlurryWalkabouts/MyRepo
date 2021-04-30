CREATE TABLE [history].[Metadata]
(
	[DataSource]         VARCHAR (10)  NOT NULL,
	[Connector]          VARCHAR (100) NOT NULL,
	[OriginalColumnName] VARCHAR (100) NOT NULL,
	[TABLE_NAME]         VARCHAR (100) NOT NULL,
	[COLUMN_NAME]        VARCHAR (100) NOT NULL,
	[DATA_TYPE]          VARCHAR (35)  NULL,
	[ORDINAL_POSITION]   INT           NOT NULL,
	[ValidFrom]          DATETIME2 (0) NOT NULL,
	[ValidTo]            DATETIME2 (0) NOT NULL,
)