CREATE TABLE [monitoring].[RowsNotConnecting]
(
	DatabaseName      NVARCHAR (32)  NOT NULL,
	SchemaName        NVARCHAR (32)  NOT NULL,
	TableName         NVARCHAR (64)  NOT NULL,
	SourceDatabaseKey INT            NOT NULL,
	PrimaryKey        NVARCHAR (128) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	RowNumber         INT            NOT NULL,
	AuditDWKey        INT            NOT NULL,
	ValidFrom         DATETIME2 (0)  NOT NULL,
	ValidTo           DATETIME2 (0)  NOT NULL,
	NewValidTo        DATETIME2 (0)  NOT NULL,
	CONSTRAINT [PK_RowsNotConnecting] PRIMARY KEY CLUSTERED ([DatabaseName] ASC, [SchemaName] ASC, [TableName] ASC, [SourceDatabaseKey] ASC, [PrimaryKey] ASC, [RowNumber] ASC)
)