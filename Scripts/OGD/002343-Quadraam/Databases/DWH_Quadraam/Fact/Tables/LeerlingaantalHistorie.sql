CREATE TABLE [Fact].[LeerlingaantalHistorie]
(
	[JaarKey]					INT				NOT NULL,
	[KostenplaatsKey]			INT				NOT NULL,
	[Afdeling]					[nvarchar](50)	NULL,
	[ElementCode]				[int]			NULL,
	[OpleidingsNaam]			[nvarchar](75)	NULL,
	[IsLWOO_indicatie]			[int]			NOT NULL,
	[OnderwijsType]				[nvarchar](25)	NULL,
	[VMBO_Sector]				[nvarchar](20)	NULL,
	[leerjaar]					[int]			NULL,
	[Geslacht]					[varchar](1)	NOT NULL,
	[AantalLeerlingen]			[int]			NULL
	CONSTRAINT [FK_LeerlingaantalUitgebreid_JaarKey] FOREIGN KEY ([JaarKey]) REFERENCES [Dim].[Jaar]([JaarKey]),
	CONSTRAINT [FK_LeerlingaantalUitgebreid_KostenplaatsKey] FOREIGN KEY ([KostenplaatsKey]) REFERENCES [Dim].[Kostenplaats]([KostenplaatsKey]),
)