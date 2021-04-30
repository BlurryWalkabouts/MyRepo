CREATE TABLE [Fact].[Werkgeverskosten]
(
	[MaandKey]					INT				NOT NULL,
	[MaandMutatieKey]			INT				NOT NULL,
	[KostenplaatsKey]			INT				NOT NULL,
	[KostendragerKey]			INT				NOT NULL,
	[GrootboekKey]				INT				NOT NULL,
	[LooncomponentKey]			INT				NOT NULL,
	[DienstverbandKey]			INT				NOT NULL,
	[MedewerkerKey]					INT				NOT NULL,
	[SaldoWerkgeverskosten]		DECIMAL(8,2)	NULL,
	[AantalMutaties]			TINYINT			NULL
	CONSTRAINT [FK_Werkgeverskosten_KostenplaatsKey] FOREIGN KEY ([KostenplaatsKey]) REFERENCES [Dim].[Kostenplaats]([KostenplaatsKey]),
	CONSTRAINT [FK_Werkgeverskosten_KostendragerKey] FOREIGN KEY ([KostendragerKey]) REFERENCES [Dim].[Kostendrager]([KostendragerKey]),
	CONSTRAINT [FK_Werkgeverskosten_GrootboekKey] FOREIGN KEY ([GrootboekKey]) REFERENCES [Dim].[Grootboek]([GrootboekKey]),
	CONSTRAINT [FK_Werkgeverskosten_LooncomponentKey] FOREIGN KEY ([LooncomponentKey]) REFERENCES [Dim].[Looncomponent]([LooncomponentKey]),
	CONSTRAINT [FK_Werkgeverskosten_MaandKey] FOREIGN KEY ([MaandKey]) REFERENCES [Dim].[Maand]([MaandKey]),
	CONSTRAINT [FK_Werkgeverskosten_MaandMutatieKey] FOREIGN KEY ([MaandMutatieKey]) REFERENCES [Dim].[Maand]([MaandKey]),
	CONSTRAINT [FK_Werkgeverskosten_DienstverbandKey] FOREIGN KEY ([DienstverbandKey]) REFERENCES [Dim].[Dienstverband]([DienstverbandKey]),
	CONSTRAINT [FK_Werkgeverskosten_MedewerkerKey] FOREIGN KEY ([MedewerkerKey]) REFERENCES [Dim].[Medewerker]([MedewerkerKey]),
)