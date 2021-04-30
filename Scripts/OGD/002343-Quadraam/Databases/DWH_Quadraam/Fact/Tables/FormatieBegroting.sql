CREATE TABLE [Fact].[FormatieBegroting]
(
	MaandKey					INT					NOT NULL,
	KostenplaatsKey				INT					NOT NULL,
	MedewerkerKey				INT					NOT NULL,
	Opmerking					NVARCHAR(512)		NOT NULL,
	Dienstbetrekking			VARCHAR(25)			NOT NULL,
	WTF							DECIMAL(10,4)		NOT NULL,
	TU							DECIMAL(10,4)		NOT NULL,
	BAPO						DECIMAL(10,4)		NOT NULL,
	BegroteFTE_bruto			DECIMAL(10,4)		NOT NULL,
	BegroteFTE_netto			DECIMAL(10,4)		NOT NULL,
	LoonkostenBudget			DECIMAL(10,4)		NOT NULL,

	CONSTRAINT [FK_FormatieBegroting_KostenplaatsKey] FOREIGN KEY ([KostenplaatsKey]) REFERENCES [Dim].[Kostenplaats]([KostenplaatsKey]),
	CONSTRAINT [FK_FormatieBegroting_MaandKey] FOREIGN KEY (MaandKey) REFERENCES [Dim].[Maand](MaandKey),
	CONSTRAINT [FK_FormatieBegroting_MedewerkerKey] FOREIGN KEY (MedewerkerKey) REFERENCES [Dim].[Medewerker](MedewerkerKey)
)