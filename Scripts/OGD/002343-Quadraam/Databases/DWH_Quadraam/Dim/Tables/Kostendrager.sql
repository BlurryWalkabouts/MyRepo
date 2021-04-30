CREATE TABLE [Dim].[Kostendrager]
(
	[KostendragerKey]		INT				IDENTITY (1,1) NOT FOR REPLICATION,
	[KostendragerCode]		NVARCHAR (16)	NULL,
	[KostendragerNaam]		NVARCHAR (50)	NULL,
	CONSTRAINT [PK_Kostendrager] PRIMARY KEY ([KostendragerKey])
)