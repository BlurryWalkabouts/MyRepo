CREATE TABLE [Dim].[Users]
(
	[Code]              NVARCHAR (250) NOT NULL,
	[Name]              NVARCHAR (250) NULL,
	[SecurityClearance] NVARCHAR (250) NULL,
	[LastChgDateTime]   DATETIME2 (3)  NOT NULL,
	CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([Code] ASC)
)