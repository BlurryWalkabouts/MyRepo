CREATE TABLE [Afas].[DWH_HR_Formatieverdeling] (
    [Begindatum]          DATETIME2 (0)  NULL,
    [Einddatum]           DATETIME2 (0)  NULL,
    [Kostendrager_code]   NVARCHAR (30)  NULL,
    [Kostenplaats_code]   NVARCHAR (30)  NULL,
    [Orgeenheidcode]      NVARCHAR (10)  NULL,
    [Medewerker]          NVARCHAR (15)  NULL,
    [Percentage]          DECIMAL (6, 2) NULL,
    [DV]                  INT            NULL,
    [Functiecode]         NVARCHAR (10)  NULL,
    [Functie]             NVARCHAR (50)  NULL,
    [Org_eenheid]         NVARCHAR (50)  NULL,
    [Kostenplaats]        NVARCHAR (50)  NULL,
    [Kostendrager]        NVARCHAR (50)  NULL,
    [Type_functie]        NVARCHAR (50)  NULL,
    [Functietype]         NVARCHAR (10)  NULL,
    [BRINinstelling]      NVARCHAR (4)   NULL,
    [Volgnummer_contract] INT            NULL,
    [BRIN]                NVARCHAR (80)  NULL,
    [Werkgever]           NVARCHAR (15)  NULL,
    [Naam_werkgever]      NVARCHAR (255) NULL
);



