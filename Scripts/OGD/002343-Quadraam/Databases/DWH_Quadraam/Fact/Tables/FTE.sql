CREATE TABLE [Fact].[FTE]
(
	[MaandKey]                   INT		   NOT NULL,
	[FunctieKey]                 INT		   NOT NULL,
	[FTE_TU]                     DECIMAL(8,4)  NOT NULL,
	[FTE_Bruto]                  DECIMAL(8,4)  NOT NULL,
	[FTE_BAPO]                   DECIMAL(8,4)  NOT NULL,
	[FTE_Spaar_BAPO]             DECIMAL(8,4)  NOT NULL,
	[FTE_Detachering]            DECIMAL(8,4)  NOT NULL,
	[FTE_Spaarverlof]            DECIMAL(8,4)  NOT NULL,
	[FTE_Ouderschapsverlof]      DECIMAL(8,4)  NOT NULL,
	[FTE_Zwangerschapsverlof]    DECIMAL(8,4)  NOT NULL,
	[FTE_Onbetaald_Verlof]       DECIMAL(8,4)  NOT NULL,
	[FTE_Netto]                  DECIMAL(8,4)  NOT NULL,
	CONSTRAINT [FK_FTE_MaandKey] FOREIGN KEY ([MaandKey]) REFERENCES [Dim].[Maand]([MaandKey]),
	CONSTRAINT [FK_FTE_FunctieKey] FOREIGN KEY ([FunctieKey]) REFERENCES [Dim].[Functie]([FunctieKey]),
)