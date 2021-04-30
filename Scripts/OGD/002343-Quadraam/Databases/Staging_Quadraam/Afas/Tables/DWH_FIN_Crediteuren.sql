CREATE TABLE [Afas].[DWH_FIN_Crediteuren] (
    [Crediteur]               NVARCHAR (16)  NULL,
    [Crediteurnaam]           NVARCHAR (80)  NULL,
    [Zoeknaam]                NVARCHAR (10)  NULL,
    [Adres]                   NVARCHAR (255) NULL,
    [Postcode]                NVARCHAR (15)  NULL,
    [Woonplaats]              NVARCHAR (50)  NULL,
    [Land]                    NVARCHAR (3)   NULL,
    [BTWnummer]               NVARCHAR (21)  NULL,
    [Debiteurennummer]        NVARCHAR (14)  NULL,
    [Bank_girorekeningnummer] NVARCHAR (40)  NULL,
    [Grekening]               NVARCHAR (40)  NULL,
    [IBAN]                    NVARCHAR (40)  NULL,
    [Nummer_KvK]              NVARCHAR (30)  NULL,
    [Vervaldagen]             INT            NULL,
    [Automatisch_betalen]     BIT            NULL,
    [Voorkeur_tegenrekening]  NVARCHAR (16)  NULL,
    [Debiteurnr_leverancier]  NVARCHAR (14)  NULL,
    [Betaalvoorwaarde]        NVARCHAR (5)   NULL,
    [Tijdelijk_blokkeren]     BIT            NULL,
    [Volledig_blokkeren]      BIT            NULL
);

