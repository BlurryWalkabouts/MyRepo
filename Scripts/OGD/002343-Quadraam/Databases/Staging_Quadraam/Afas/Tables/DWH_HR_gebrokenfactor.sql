CREATE TABLE [Afas].[DWH_HR_Gebrokenfactor] (
    [Totaalbedrag]              DECIMAL (11, 2) NULL,
    [Medewerker]                NVARCHAR (15)   NULL,
    [Naam]                      NVARCHAR (80)   NULL,
    [Looncomponent]             INT             NULL,
    [Omschrijving]              NVARCHAR (80)   NULL,
    [Stamnummer]                INT             NULL,
    [Boekjaar]                  INT             NULL,
    [Periode]                   INT             NULL,
    [Dienstverband]             INT             NULL,
    [Gebroken_maand_berekening] BIT             NULL,
    [Werkgever]                 NVARCHAR (15)   NULL,
    [Volgnummer_contract]       INT             NULL
);



