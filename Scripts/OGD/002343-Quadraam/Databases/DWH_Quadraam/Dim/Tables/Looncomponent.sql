CREATE TABLE [Dim].[Looncomponent]
(
	[LooncomponentKey]		INT				IDENTITY (1,1) NOT FOR REPLICATION,
	[Looncomponent]			INT				NOT NULL,
	[Grondslag]				NVARCHAR (60)	NOT NULL,
	CONSTRAINT [PK_Looncomponent] PRIMARY KEY ([LooncomponentKey])
)