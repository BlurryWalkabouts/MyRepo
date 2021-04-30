CREATE TABLE [log].[ProcedureLog]
(
	[Batch]			SMALLINT		NULL,
	[Starttijd]		DATETIME2		NULL,
	[Eindtijd]		DATETIME2		NULL,
	[Script]		VARCHAR (40)	NULL,
	[IsGeslaagd]	BIT				NULL,
	[Melding]		VARCHAR (200)	NULL,
	[Duration]		AS				DATEDIFF(SECOND, [Starttijd], [Eindtijd])
)