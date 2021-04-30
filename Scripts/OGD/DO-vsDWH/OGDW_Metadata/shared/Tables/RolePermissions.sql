CREATE TABLE [shared].[RolePermissions]
(
	[RecordID]        INT          IDENTITY (1,1) NOT FOR REPLICATION,
	[DatabaseName]    VARCHAR (64) NOT NULL,
	[SchemaName]      VARCHAR (64) NOT NULL,
	[TableName]       VARCHAR (64) NOT NULL,
	[ColumnName]      VARCHAR (64) NOT NULL,
	[RoleName]        VARCHAR (64) NOT NULL,
	[OrdinalPosition] TINYINT      NULL,
	[GrantSelect]     TINYINT      NOT NULL DEFAULT 0,
	CONSTRAINT [PK_RolePermissions] PRIMARY KEY CLUSTERED ([RecordID] ASC, [DatabaseName] ASC)
)