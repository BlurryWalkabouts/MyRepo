CREATE TABLE [Afas].[DWH_HR_Rooster] (
    [Medewerker]              NVARCHAR (15)   NULL,
    [Dienstverband]           INT             NULL,
    [Begindatum_rooster]      DATETIME2 (0)   NULL,
    [Einddatum_rooster]       DATETIME2 (0)   NULL,
    [Aantal_dagen_per_week]   DECIMAL (3, 2)  NULL,
    [Aantal_uren_per_week]    DECIMAL (8, 5)  NULL,
    [Aantal_uren_per_dag]     DECIMAL (8, 5)  NULL,
    [Volgnummer_rooster]      INT             NULL,
    [FTE]                     DECIMAL (8, 4)  NULL,
    [BAPO_FTE]                DECIMAL (10, 7) NULL,
    [Spaar_BAPO_FTE]          DECIMAL (10, 7) NULL,
    [BAPOuren_per_week]       DECIMAL (8, 5)  NULL,
    [Spaar_BAPOuren_per_week] DECIMAL (8, 5)  NULL,
    [Geboortedatum]           DATETIME2 (0)   NULL,
    [FTE_Zondag]              DECIMAL (10, 7) NULL,
    [FTE_Maandag]             DECIMAL (10, 7) NULL,
    [FTE_Dinsdag]             DECIMAL (10, 7) NULL,
    [FTE_Woensdag]            DECIMAL (10, 7) NULL,
    [FTE_Donderdag]           DECIMAL (10, 7) NULL,
    [FTE_Vrijdag]             DECIMAL (10, 7) NULL,
    [FTE_Zaterdag]            DECIMAL (10, 7) NULL,
    [Koppeling_contract]      INT             NULL
);







