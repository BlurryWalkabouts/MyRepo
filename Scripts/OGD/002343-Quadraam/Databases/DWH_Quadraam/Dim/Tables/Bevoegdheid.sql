CREATE TABLE [Dim].[Bevoegdheid] (
	[BevoegdheidKey]		INT			   IDENTITY (1,1) NOT FOR REPLICATION,
    [MedewerkerKey]         INT            NOT NULL,
    [BegindatumOpleiding]   DATE           NOT NULL,
    [EinddatumOpleiding]    DATE           NOT NULL,
    [ResultaatOpleiding]    NVARCHAR (100) NOT NULL,
    [HeeftDiploma]          BIT            NOT NULL,
    [OmschrijvingOpleiding] NVARCHAR (100) NOT NULL,
    [OpleidingsType]        NVARCHAR (10)  NOT NULL,
    [VakBevoegdheid]        NVARCHAR (100) NOT NULL,
    [Bevoegdheidsgraad]     NVARCHAR (100) NOT NULL,
	CONSTRAINT [PK_Bevoegdheid] PRIMARY KEY ([BevoegdheidKey])
);

