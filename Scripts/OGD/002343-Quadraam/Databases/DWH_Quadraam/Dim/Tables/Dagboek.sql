CREATE TABLE [Dim].[Dagboek]
(
	[DagboekKey]			INT				IDENTITY (1,1) NOT FOR REPLICATION,
	[DagboekCode]			NVARCHAR(6)		NULL,
	[DagboekNaam]			NVARCHAR(50)	NULL,
	[DagboekType]			NVARCHAR(20)	NULL,
	[Boekstuknummer]		NVARCHAR(21)	NULL,
	CONSTRAINT [PK_Dagboek] PRIMARY KEY ([DagboekKey])
)