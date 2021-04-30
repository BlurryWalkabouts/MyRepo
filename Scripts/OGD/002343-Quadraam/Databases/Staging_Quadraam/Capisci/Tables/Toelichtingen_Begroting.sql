CREATE TABLE [Capisci].[Toelichtingen_Begroting] (
    [kostenplaats]              NVARCHAR (16)  NULL,
    [kostenplaats_omschrijving] NVARCHAR (255) NULL,
    [rekening]                  NVARCHAR (16)  NULL,
    [rekening_omschrijving]     NVARCHAR (255) NULL,
    [jaar_van]                  INT            NULL,
    [periode_van]               TINYINT        NULL,
    [jaar_tot]                  INT            NULL,
    [periode_tot]               TINYINT        NULL,
    [opmerking]                 NVARCHAR (MAX) NULL
);

