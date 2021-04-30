CREATE TABLE [Afas].[DWH_HR_Medewerker_journaalpost] (
    [Grondslag]                      INT             NULL,
    [Medewerker]                     NVARCHAR (15)   NULL,
    [Looncomponent]                  INT             NULL,
    [Kostenplaats]                   NVARCHAR (30)   NULL,
    [Kostendrager]                   NVARCHAR (30)   NULL,
    [Dienstverband]                  INT             NULL,
    [Geaccordeerd]                   DATETIME2 (0)   NULL,
    [Jaar]                           INT             NULL,
    [Periode]                        INT             NULL,
    [Grootboekrekening]              NVARCHAR (16)   NULL,
    [Omschrijving_grootboekrekening] NVARCHAR (40)   NULL,
    [Omschrijving_klant]             NVARCHAR (80)   NULL,
    [Bedrag_debet]                   DECIMAL (16, 5) NULL,
    [Bedrag_credit]                  DECIMAL (16, 5) NULL,
    [Organisatorische_eenheid]       NVARCHAR (10)   NULL,
    [Omschrijving]                   NVARCHAR (50)   NULL,
    [Onderwijsinstelling]            NVARCHAR (15)   NULL
);

