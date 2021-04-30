CREATE TABLE [Capisci].[Begroting_formatie] (
    [kostenplaats]              NVARCHAR (16)   NULL,
    [kostenplaats_omschrijving] NVARCHAR (255)  NULL,
    [code]                      NVARCHAR (255)  NULL,
    [personeelsnummer]          INT             NULL,
    [naam]                      NVARCHAR (255)  NULL,
    [jaar]                      INT             NULL,
    [periode]                   INT             NULL,
    [wtf]                       DECIMAL (10, 4) NULL,
    [tu]                        DECIMAL (10, 4) NULL,
    [lbp]                       DECIMAL (10, 4) NULL,
    [salarisschaal]             NVARCHAR (255)  NULL,
    [contractsoort]             NVARCHAR (255)  NULL,
    [loonkosten]                DECIMAL (10, 4) NULL
);

