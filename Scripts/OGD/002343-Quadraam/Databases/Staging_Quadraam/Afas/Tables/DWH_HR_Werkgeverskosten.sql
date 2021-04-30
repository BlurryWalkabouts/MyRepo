CREATE TABLE [Afas].[DWH_HR_Werkgeverskosten] (
    [Grondslag]                      NVARCHAR (80)   NULL,
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
    [Functie]                        NVARCHAR (30)   NULL,
    [Bedrag_debet]                   DECIMAL (16, 5) NULL,
    [Bedrag_credit]                  DECIMAL (16, 5) NULL,
    [Organisatorische_eenheid]       NVARCHAR (10)   NULL,
    [Gewijzigd_op]                   DATETIME2 (0)   NULL,
    [Jaar_2]                         INT             NULL,
    [Periode_2]                      INT             NULL,
    [Werkgever]                      NVARCHAR (15)   NULL
);

