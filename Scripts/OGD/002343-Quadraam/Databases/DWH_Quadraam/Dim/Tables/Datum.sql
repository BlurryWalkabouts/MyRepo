CREATE TABLE [Dim].[Datum] (
    [DatumKey]       INT         NOT NULL,
    [MaandKey]       INT         NOT NULL,
    [JaarKey]        INT         NOT NULL,
    [Datum]          DATE        NOT NULL,
    [JaarNum]        SMALLINT    NOT NULL,
    [MaandNum]       TINYINT     NOT NULL,
    [MaandNaam]      VARCHAR (9) NOT NULL,
    [MaandNaamKort]  CHAR (3)    NOT NULL,
    [MaandJaarNum]   AS          (case when [MaandNaam]='' then '' else CONCAT([JaarNum],'-',case when [MaandNum]>(9) then '' else '0' end,CONVERT([nvarchar],[MaandNum])) end),
    [MaandJaarNaam]  AS          (case when [MaandNaam]='' then '' else CONCAT([MaandNaam],' ',[JaarNum]) end),
    [DagNum]         TINYINT     NOT NULL,
    [DagNaam]        VARCHAR (9) NOT NULL,
    [DagNaamKort]    CHAR (2)    NOT NULL,
    [WeekNum]        TINYINT     NOT NULL,
    [Feestdag]       BIT         NOT NULL,
    [Schoolvakantie] BIT         NOT NULL,
    [VerschilHuidigeMaand]	AS    DATEDIFF(MM,GETDATE(),Datum),
    [VerschilMetVandaag]	AS    DATEDIFF(DD,GETDATE(),Datum),
    CONSTRAINT [PK_Datum] PRIMARY KEY CLUSTERED ([DatumKey] ASC),
    CONSTRAINT [FK_Datum_Jaar] FOREIGN KEY ([JaarKey]) REFERENCES [Dim].[Jaar] ([JaarKey]),
    CONSTRAINT [FK_Datum_Maand] FOREIGN KEY ([MaandKey]) REFERENCES [Dim].[Maand] ([MaandKey])
);

