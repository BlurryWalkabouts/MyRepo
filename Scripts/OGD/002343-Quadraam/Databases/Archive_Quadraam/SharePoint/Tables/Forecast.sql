CREATE TABLE [SharePoint].[Forecast]
(
	[BudgetCode]            VARCHAR (50)                                       NOT NULL,
	[Jaar]                  INT                                                NOT NULL,
	[Maand]                 INT                                                NOT NULL,
	[KostenplaatsCode]      NVARCHAR (16)                                      NOT NULL,
	[GrootboekRekeningCode] NVARCHAR (16)                                      NOT NULL,
	[MutatieBedrag]         DECIMAL (14,4)                                     NULL,
	[Toelichting]           NVARCHAR (MAX)                                     NULL,
	[ValidFrom]             DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
	[ValidTo]               DATETIME2 (0) GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
	CONSTRAINT [PK_Forecast] PRIMARY KEY CLUSTERED ([BudgetCode] ASC, [Jaar] ASC, [Maand] ASC, [KostenplaatsCode] ASC, [GrootboekRekeningCode] ASC) WITH (DATA_COMPRESSION = PAGE),
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[history].[Forecast], DATA_CONSISTENCY_CHECK = ON));