CREATE TABLE [Fact].[Verzuim]
(
	[DatumKey]						INT				NOT NULL,
	[DienstverbandKey]				INT				NOT NULL,
	[Aanvangsdatum_Verzuim]			DATE			NOT NULL,
    [Hersteldatum_verzuim]			DATE			NOT NULL,
    [Begindatum_Ziektetijdvak]		DATE			NOT NULL,
    [Einddatum_Ziektetijdvak]		DATE			NOT NULL,
	[VerzuimType]					NVARCHAR(100)	NOT NULL,
	[IsDoorlopendVerzuim]			BIT				NOT NULL,
    [IsVangnetregeling]				BIT				NOT NULL,
	[AfwezigheidPercentage]			DECIMAL(8,4)	NOT NULL,
	[AanwezigheidPercentage]		DECIMAL(8,4)	NOT NULL,
	[Verzuimduurklasse]				NVARCHAR(25)	NOT NULL,

	CONSTRAINT [FK_Verzuim_DatumKey] FOREIGN KEY ([DatumKey]) REFERENCES [Dim].[Datum]([DatumKey]),
	CONSTRAINT [FK_Verzuim_DienstverbandKey] FOREIGN KEY ([DienstverbandKey]) REFERENCES [Dim].[Dienstverband]([DienstverbandKey]),
)