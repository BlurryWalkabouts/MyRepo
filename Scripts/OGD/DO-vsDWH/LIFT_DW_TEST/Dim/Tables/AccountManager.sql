CREATE TABLE [Dim].[AccountManager]
(
	[AccountManagerKey]  INT              NOT NULL,
	[unid]               UNIQUEIDENTIFIER NULL,
	[AccountManagerName] NVARCHAR (100)   NULL,
	[Archive]            INT              NULL,
	[Status]             INT              NULL,
	[CreationDate]       DATETIME         NULL,
	[ChangeDate]         DATETIME         NULL,
	CONSTRAINT [PK_AccountManager] PRIMARY KEY CLUSTERED ([AccountManagerKey] ASC)
)