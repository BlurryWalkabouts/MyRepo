CREATE TABLE [shared].[ForeignKeys]
(
	[ForeignKeyID] INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[DbName]       NVARCHAR (50)  NOT NULL,
	[DisableDate]  DATETIME       NOT NULL DEFAULT GETDATE(),
	[ForeignKey]   NVARCHAR (50)  NOT NULL,
	[SQLStringAdd] NVARCHAR (MAX) NOT NULL,
	CONSTRAINT [PK_ForeignKeys] PRIMARY KEY CLUSTERED ([ForeignKeyID] ASC)
)