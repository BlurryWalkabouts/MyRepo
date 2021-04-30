CREATE TABLE [Fact].[LeerlingaantalBegroot]
(
	[JaarKey]					INT			NOT NULL,
	[KostenplaatsKey]			INT			NOT NULL,
	[OnderwijsSoort]			VARCHAR(25)	NOT NULL,
	[AantalLeerlingen]			SMALLINT	NULL,
	CONSTRAINT [FK_Leerlingaantal_KostenplaatsKey] FOREIGN KEY ([KostenplaatsKey]) REFERENCES [Dim].[Kostenplaats]([KostenplaatsKey]),
	CONSTRAINT [FK_Leerlingaantal_JaarKey] FOREIGN KEY ([JaarKey]) REFERENCES [Dim].[Jaar]([JaarKey]),
)