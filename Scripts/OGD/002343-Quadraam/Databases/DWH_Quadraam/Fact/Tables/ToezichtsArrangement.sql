CREATE TABLE [Fact].[ToezichtsArrangement] (
    [JaarKey]              INT            NOT NULL,
    [KostenplaatsKey]      INT            NOT NULL,
    [Onderwijssoort]       VARCHAR (25)   NOT NULL,
    [ToezichtsArrangement] NVARCHAR (50)  NOT NULL,
	CONSTRAINT [FK_ToezichtsArrangement_KostenplaatsKey] FOREIGN KEY ([KostenplaatsKey]) REFERENCES [Dim].[Kostenplaats]([KostenplaatsKey]),
	CONSTRAINT [FK_ToezichtsArrangement_JaarKey] FOREIGN KEY ([JaarKey]) REFERENCES [Dim].[Jaar]([JaarKey]),
);

