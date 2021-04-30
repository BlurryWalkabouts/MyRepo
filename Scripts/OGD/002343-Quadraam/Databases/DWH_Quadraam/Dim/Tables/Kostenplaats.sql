CREATE TABLE [Dim].[Kostenplaats]
(
	[KostenplaatsKey]	INT				IDENTITY (1,1) NOT FOR REPLICATION,
	[KostenplaatsCode]	NVARCHAR (16)	NULL,
	[KostenplaatsNaam]	NVARCHAR (50)	NULL,
	[BRIN_Nummer]		VARCHAR (20)	NULL,
	[Instelling]		VARCHAR (50)	NULL,
	[VestigingsNummer]	VARCHAR (20)	NULL,
	LogoURL				VARCHAR (100)	NULL,
	CONSTRAINT [PK_Kostenplaats] PRIMARY KEY ([KostenplaatsKey])
)