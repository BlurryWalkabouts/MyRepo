CREATE TABLE [Afas].[DWH_FIN_Periodes] (
    [Periodetabel] INT           NULL,
    [Boekjaar]     INT           NULL,
    [Periode]      INT           NULL,
    [Omschrijving] NVARCHAR (30) NULL,
    [Datum_van]    DATETIME2 (0) NULL,
    [Datum_t_m]    DATETIME2 (0) NULL,
    [Geblokkeerd]  BIT           NULL
);

