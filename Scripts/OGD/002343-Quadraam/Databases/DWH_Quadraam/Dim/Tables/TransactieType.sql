CREATE TABLE [Dim].[TransactieType]
(
	[TransactieTypeKey]   INT			IDENTITY (1,1) NOT FOR REPLICATION,
	[TransactieTypeCode]  CHAR (1)      NULL,
	[TransactieTypeNaam]  VARCHAR (100) NULL
	CONSTRAINT [PK_TransactieType] PRIMARY KEY ([TransactieTypeKey])
)