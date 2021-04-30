CREATE TABLE [history].[Forecast]
(
	[BudgetCode]            VARCHAR (50)   NOT NULL,
	[Jaar]                  INT            NOT NULL,
	[Maand]                 INT            NOT NULL,
	[KostenplaatsCode]      NVARCHAR (16)  NOT NULL,
	[GrootboekRekeningCode] NVARCHAR (16)  NOT NULL,
	[MutatieBedrag]         DECIMAL (14,4) NULL,
	[Toelichting]           NVARCHAR (MAX) NULL,
	[ValidFrom]             DATETIME2 (0)  NOT NULL,
	[ValidTo]               DATETIME2 (0)  NOT NULL,
)