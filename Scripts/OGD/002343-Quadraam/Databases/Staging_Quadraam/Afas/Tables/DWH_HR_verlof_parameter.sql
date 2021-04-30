CREATE TABLE [Afas].[DWH_HR_Verlof_parameter] (
    [Component]          INT             NULL,
    [Volgnummer]         INT             NULL,
    [Dienstverband]      INT             NULL,
    [Parameter]          INT             NULL,
    [Omschrijving_klant] NVARCHAR (80)   NULL,
    [Begindatum]         DATETIME2 (0)   NULL,
    [Einddatum]          DATETIME2 (0)   NULL,
    [Waarde]             DECIMAL (16, 5) NULL,
    [Waarde_2]           NVARCHAR (10)   NULL,
    [Stamnummer]         INT             NULL,
    [Nummer_component]   INT             NULL,
    [Medewerker]         NVARCHAR (15)   NULL,
    [Toepassing_code]    NVARCHAR (20)   NULL
);

