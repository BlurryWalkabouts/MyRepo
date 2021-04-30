CREATE TABLE [Dim].[Factuur]
(
	[FactuurKey]					INT				IDENTITY (1,1) NOT FOR REPLICATION,
	[FactuurNummer]					NVARCHAR(12)	NULL,
	[FactuurNummerExtern]			NVARCHAR(32)	NULL,
	[FactuurDatum]					DATE			NULL,
	[FactuurOmschrijving]			NVARCHAR(50)	NULL,
	[FactuurURL]					NVARCHAR(250)	NULL,
	CONSTRAINT [PK_Factuur] PRIMARY KEY ([FactuurKey])
)