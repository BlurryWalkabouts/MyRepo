CREATE TABLE [Afas].[DWH_FIN_BTWcode] (
    [BTWcode]        NVARCHAR (3)   NULL,
    [Omschrijving]   NVARCHAR (80)  NULL,
    [BTW_rekening]   NVARCHAR (16)  NULL,
    [BTW_plicht]     NVARCHAR (3)   NULL,
    [Geblokkeerd]    BIT            NULL,
    [BTW_percentage] DECIMAL (5, 2) NULL
);

