CREATE TABLE [setup].[DWDatabases]
(
	[id]                INT          IDENTITY(1,1),
	[code]              VARCHAR (20) NULL,
	[database_fullname] SYSNAME      NOT NULL,
	[staging_schema]    VARCHAR (20) NULL
)