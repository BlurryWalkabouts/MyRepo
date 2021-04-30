CREATE TABLE [Afas].[DWH_HR_Ziekteverzuim] (
    [Einddatum_connector]              DATETIME2 (0)  NULL,
    [Begindatum_connector]             DATETIME2 (0)  NULL,
    [Medewerker]                       NVARCHAR (15)  NULL,
    [Werkgever]                        NVARCHAR (15)  NULL,
    [Totaal_doorlopende_dagen_verzuim] INT            NULL,
    [Type_verzuim_code]                NVARCHAR (20)  NULL,
    [Reden_verzuim_code]               NVARCHAR (20)  NULL,
    [Aanwezigheid]                     DECIMAL (6, 2) NULL,
    [Aanwezig_eerste_dag]              INT            NULL,
    [Dienstverband]                    INT            NULL,
    [Begindatum]                       DATETIME2 (0)  NULL,
    [Type_verzuim]                     NVARCHAR (100) NULL,
    [Reden_verzuim]                    NVARCHAR (100) NULL,
    [Doorlopend_verzuim]               BIT            NULL,
    [Vangnetregeling]                  BIT            NULL,
    [Einddatum]                        DATETIME2 (0)  NULL
);







