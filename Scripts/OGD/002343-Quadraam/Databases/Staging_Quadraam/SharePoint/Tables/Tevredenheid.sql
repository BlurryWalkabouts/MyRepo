CREATE TABLE [SharePoint].[Tevredenheid] (
    [ID]                      INT            NULL,
    [KostenplaatsCode]        NVARCHAR (16)  NULL,
    [Jaar]                    INT            NULL,
    [TevredenheidLeerlingen]  DECIMAL (3, 1) NULL,
    [DoelstellingLeerlingen]  DECIMAL (3, 1) NULL,
    [NormLeerlingen]          DECIMAL (3, 1) NULL,
    [TevredenheidMedewerkers] DECIMAL (3, 1) NULL,
    [TevredenheidManagement]  DECIMAL (3, 1) NULL,
    [TevredenheidDocenten]    DECIMAL (3, 1) NULL,
    [TevredenheidOOP]         DECIMAL (3, 1) NULL,
    [DoelstellingMedewerkers] DECIMAL (3, 1) NULL,
    [DoelstellingManagement]  DECIMAL (3, 1) NULL,
    [DoelstellingDocenten]    DECIMAL (3, 1) NULL,
    [DoelstellingOOP]         DECIMAL (3, 1) NULL,
    [NormMedewerkers]         DECIMAL (3, 1) NULL,
    [TevredenheidOuders]      DECIMAL (3, 1) NULL,
    [DoelstellingOuders]      DECIMAL (3, 1) NULL,
    [NormOuders]              DECIMAL (3, 1) NULL,
    [Gewijzigd]               DATETIME2 (3)  NULL,
    [Gemaakt]                 DATETIME2 (3)  NULL
);

