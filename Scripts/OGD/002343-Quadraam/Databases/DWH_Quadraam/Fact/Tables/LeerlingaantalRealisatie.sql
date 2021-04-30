CREATE TABLE [Fact].[LeerlingaantalRealisatie] (
    [KostenplaatsKey] INT         NOT NULL,
    [JaarKey]         INT         NOT NULL,
    [Leerjaar]        INT         NULL,
    [Leerjaargroep]   VARCHAR (3) NULL,
    [VSO_Opname]      INT         NULL,
    [VSO_Verwijzing]  INT         NULL,
    [LWOO]            INT         NULL,
    [PRO]             INT         NULL,
    [Instroom]        INT         NULL,
    [Totaal]          INT         NULL,
	CONSTRAINT [FK_LeerlingaantalRealisatie_KostenplaatsKey] FOREIGN KEY ([KostenplaatsKey]) REFERENCES [Dim].[Kostenplaats]([KostenplaatsKey]),
	CONSTRAINT [FK_LeerlingaantalRealisatie_MaandKey] FOREIGN KEY (JaarKey) REFERENCES [Dim].Jaar(JaarKey),
);

