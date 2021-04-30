CREATE TABLE [SharePoint].[Leerlingaantallen] (
    [Kostenplaats]              NVARCHAR (16)  NOT NULL,
    [Jaar]                      INT            NULL,
    [Leerjaar]                  INT            NULL,
    [Aantal lln VSO opname]     INT            NULL,
    [Aantal lln VSO verwijzing] INT            NULL,
    [Aantal lln LWOO indicatie] INT            NULL,
    [Aantal lln PRO indicatie]  INT            NULL,
    [Instroom]                  NVARCHAR (255) NULL,
    [Totaal aantal leerlingen]  INT            NULL,
    [Gewijzigd]                 DATETIME2 (3)  NULL,
    [Gemaakt]                   DATETIME2 (3)  NULL
);

