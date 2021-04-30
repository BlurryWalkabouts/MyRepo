CREATE TABLE [Dim].[Scenario]
(
	[ScenarioKey]			INT				IDENTITY (1,1) NOT FOR REPLICATION,
	[ScenarioCode]			CHAR (8)		NULL,
	[ScenarioNaam]			VARCHAR (30)	NULL,
	[Boekjaar]				SMALLINT		NULL,
	[Source]				CHAR			NULL,
	CONSTRAINT [PK_Scenario] PRIMARY KEY ([ScenarioKey])
)