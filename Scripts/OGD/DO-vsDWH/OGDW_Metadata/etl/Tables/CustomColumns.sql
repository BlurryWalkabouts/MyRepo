CREATE TABLE [etl].[CustomColumns]
(
	[TABLE_NAME]        NVARCHAR (255) NOT NULL,
	[COLUMN_NAME]       NVARCHAR (255) NOT NULL,
	[ColumnDefinition]  NVARCHAR (255) NOT NULL,
	[SourceDatabaseKey] INT            NOT NULL,
	[AuditDWKey]        INT            NOT NULL
)