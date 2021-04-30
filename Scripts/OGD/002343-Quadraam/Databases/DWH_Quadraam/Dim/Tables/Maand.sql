CREATE TABLE [Dim].[Maand]
(
	[MaandKey]			INT				NOT NULL,
	[JaarNum]			SMALLINT		NOT NULL,
	[MaandNum]			TINYINT			NOT NULL,
	[MaandNaam]			VARCHAR(9)		NOT NULL,
	[MaandNaamKort]		CHAR(3)			NOT NULL,
	[MaandJaarNum]		VARCHAR(15)     NOT NULL,
	[MaandJaarNaam]		VARCHAR(15)     NOT NULL,
	CONSTRAINT [PK_Maand] PRIMARY KEY ([MaandKey])
)