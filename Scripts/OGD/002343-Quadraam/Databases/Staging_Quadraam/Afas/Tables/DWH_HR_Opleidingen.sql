CREATE TABLE [Afas].[DWH_HR_Opleidingen] (
    [Werkgever]              INT            NULL,
    [Medewerker]             NVARCHAR (15)  NULL,
    [Begindatum_opleiding]   DATETIME2 (0)  NULL,
    [Einddatum_opleiding]    DATETIME2 (0)  NULL,
    [Resultaat_opleiding]    NVARCHAR (100) NULL,
    [Opmerking]              NVARCHAR (MAX) NULL,
    [Diploma]                BIT            NULL,
    [Soort_opleiding]        NVARCHAR (10)  NULL,
    [Omschrijving_opleiding] NVARCHAR (100) NULL,
    [Opleidings_werkniveau]  INT            NULL,
    [Rangnummer]             INT            NULL,
    [Code_opleiding]         NVARCHAR (10)  NULL,
    [Omschrijving_niveau]    NVARCHAR (50)  NULL
);



