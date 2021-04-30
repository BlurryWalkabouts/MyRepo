CREATE TABLE [setup].[DWColumns]
(
	[id]               INT            IDENTITY(0,1),
	[TABLE_NAME]       SYSNAME        NOT NULL,
	[COLUMN_NAME]      SYSNAME        NOT NULL,
	[column_fulltype]  VARCHAR (MAX)  NULL,
	[ordinal_position] INT            NULL,
	[import]           BIT            DEFAULT 0 NULL,
	[keep_history]     BIT            DEFAULT 0 NULL,
	[compare]          BIT            DEFAULT 1 NULL,
	[comment]          NVARCHAR (MAX) NULL,
	[deleted]          BIT            DEFAULT 0 NULL,
	[datecreated]      DATETIME2 (0)  DEFAULT SYSDATETIME() NULL
)