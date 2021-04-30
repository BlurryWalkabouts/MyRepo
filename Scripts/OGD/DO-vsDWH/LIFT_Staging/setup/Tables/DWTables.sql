CREATE TABLE [setup].[DWTables]
(
	[id]          INT            IDENTITY(0,1),
	[TABLE_NAME]  SYSNAME        NOT NULL,
	[import]      BIT            DEFAULT 0 NULL,
	[comment]     NVARCHAR (MAX) NULL,
	[deleted]     BIT            DEFAULT 0 NULL,
	[datecreated] DATETIME2 (0)  DEFAULT SYSDATETIME() NULL
)