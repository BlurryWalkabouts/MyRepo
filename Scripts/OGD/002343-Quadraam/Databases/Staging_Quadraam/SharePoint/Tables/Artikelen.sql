CREATE TABLE [SharePoint].[Artikelen] (
    [Merk]                      NVARCHAR (100) NULL,
    [TypeApparaat]              NVARCHAR (100) NULL,
    [Omschrijving]              NVARCHAR (100) NULL,
    [PrijsInclBTW]              DECIMAL (8, 2) NULL,
    [GarantietermijnJaren]      INT            NULL,
    [InvesteringsaanvraagNodig] BIT            NULL,
    [Gemaakt]                   DATETIME       NULL,
    [Gewijzigd]                 DATETIME       NULL
);

