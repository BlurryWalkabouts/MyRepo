CREATE TABLE [Afas].[DWH_HR_Loopbaanhistorie] (
    [Ambtstijd]      BIT           NULL,
    [Begindatum]     DATETIME2 (0) NULL,
    [Einddatum]      DATETIME2 (0) NULL,
    [Onderwijstijd]  BIT           NULL,
    [Bestuurtijd]    BIT           NULL,
    [Jaren]          INT           NULL,
    [Maanden]        INT           NULL,
    [Kalenderdagen]  INT           NULL,
    [Schooltijd]     BIT           NULL,
    [Medewerker]     NVARCHAR (15) NULL,
    [Directietijd]   BIT           NULL,
    [Uitkeringstijd] BIT           NULL,
    [Zorgtijd]       BIT           NULL,
    [Werkgever]      NVARCHAR (15) NULL
);

