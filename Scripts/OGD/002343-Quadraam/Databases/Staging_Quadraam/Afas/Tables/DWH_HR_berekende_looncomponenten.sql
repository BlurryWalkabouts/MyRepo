CREATE TABLE [Afas].[DWH_HR_Berekende_looncomponenten] (
    [Totaalbedrag]             DECIMAL (11, 2) NULL,
    [Geaccordeerd]             DATETIME2 (0)   NULL,
    [Boekjaar]                 INT             NULL,
    [Groep]                    NVARCHAR (100)  NULL,
    [Omschrijving]             NVARCHAR (80)   NULL,
    [Periode]                  INT             NULL,
    [Werkgever]                NVARCHAR (15)   NULL,
    [Kostenplaats]             NVARCHAR (30)   NULL,
    [Medewerker]               NVARCHAR (15)   NULL,
    [Bewerking]                NVARCHAR (100)  NULL,
    [Stamnummer]               INT             NULL,
    [Kostendrager]             NVARCHAR (30)   NULL,
    [Dienstverband]            INT             NULL,
    [Organisatorische_eenheid] NVARCHAR (10)   NULL,
    [Nummer_component]         INT             NULL
);



