CREATE TABLE [Dim].[Medewerker]
(
	[MedewerkerKey]		INT				IDENTITY (1,1) NOT FOR REPLICATION,
	[MedewerkerCode]	INT				NOT NULL,
	[MedewerkerNaam]	NVARCHAR(255)	NOT NULL,
	[Geslacht]			CHAR(1)			NOT NULL,
	[Geboortedatum]		DATE			NULL,
	[Woonplaats]		NVARCHAR(255)	NULL,
	[Email]				NVARCHAR(255)	NULL,
	[DatumInDienst]		DATE			NULL,
	[DatumInDienstIvmSignalering]			DATE			NULL,
	[DatumInDienstInclRechtsvoorganger]	DATE			NULL,
	[DatumUitDienst]	DATE			NULL,

	CONSTRAINT [PK_Medewerker] PRIMARY KEY ([MedewerkerKey])
)