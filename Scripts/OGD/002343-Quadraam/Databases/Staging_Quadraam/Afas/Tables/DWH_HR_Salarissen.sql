CREATE TABLE [Afas].[DWH_HR_Salarissen] (
    [Volgnummer_contract]      INT             NULL,
    [Schaal_code]              NVARCHAR (20)   NULL,
    [Schaal]                   NVARCHAR (100)  NULL,
    [Parttime_percentage]      DECIMAL (9, 5)  NULL,
    [Werkgever]                NVARCHAR (15)   NULL,
    [Medewerker]               NVARCHAR (15)   NULL,
    [Cao]                      NVARCHAR (15)   NULL,
    [Begindatum_salaris]       DATETIME2 (0)   NULL,
    [Einddatum_salaris]        DATETIME2 (0)   NULL,
    [Volgnummer_dienstverband] INT             NULL,
    [Trede]                    DECIMAL (9, 1)  NULL,
    [Dienstverband]            INT             NULL,
    [Salaris]                  DECIMAL (16, 5) NULL,
    [Caotype]                  NVARCHAR (100)  NULL,
    [Omschrijving]             NVARCHAR (80)   NULL,
    [Soort_onderwijs_code]     NVARCHAR (20)   NULL,
    [Soort_onderwijs]          NVARCHAR (100)  NULL,
    [Bovenschoolse_functie]    BIT             NULL,
    [Meenemen_in_GGL_PO]       BIT             NULL
);

