CREATE TABLE [Afas].[DWH_HR_Functie] (
    [Medewerker]                NVARCHAR (15)  NULL,
    [Omschrijving_kostenplaats] NVARCHAR (50)  NULL,
    [Omschrijving_kostendrager] NVARCHAR (50)  NULL,
    [Dienstverband]             INT            NULL,
    [Koppeling_contract]        INT            NULL,
    [Begindatum_functie]        DATETIME2 (0)  NULL,
    [Einddatum_functie]         DATETIME2 (0)  NULL,
    [Organisatorische_eenheid]  NVARCHAR (10)  NULL,
    [Functie]                   NVARCHAR (10)  NULL,
    [Omschrijving_functie]      NVARCHAR (50)  NULL,
    [Type_functie]              NVARCHAR (10)  NULL,
    [Omschrijving_type_functie] NVARCHAR (50)  NULL,
    [Kostenplaats]              NVARCHAR (30)  NULL,
    [Kostendrager]              NVARCHAR (30)  NULL,
    [Brin]                      NVARCHAR (15)  NULL,
    [Brin_omschrijving]         NVARCHAR (80)  NULL,
    [Werkgever]                 NVARCHAR (15)  NULL,
    [Naam_werkgever]            NVARCHAR (255) NULL
);





