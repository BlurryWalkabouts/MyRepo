CREATE TABLE [Afas].[DWH_FIN_Budget] (
    [Administratie]              INT              NULL,
    [Budgetscenario]             NVARCHAR (6)     NULL,
    [Grootboekrekening]          NVARCHAR (16)    NULL,
    [Kenmerk_rekening]           NVARCHAR (10)    NULL,
    [Jaar]                       INT              NULL,
    [Periode]                    INT              NULL,
    [Volgnummer_verbijzondering] INT              NULL,
    [Code_verbijzonderingsas_1]  NVARCHAR (16)    NULL,
    [Omschrijving]               NVARCHAR (50)    NULL,
    [Code_verbijzonderingsas_2]  NVARCHAR (16)    NULL,
    [Omschrijving2]              NVARCHAR (50)    NULL,
    [Naam]                       NVARCHAR (50)    NULL,
    [Memo]                       NVARCHAR (MAX)   NULL,
    [Bedrag_budget]              DECIMAL (26, 10) NULL,
    [Aantal_budget]              DECIMAL (10, 2)  NULL
);

