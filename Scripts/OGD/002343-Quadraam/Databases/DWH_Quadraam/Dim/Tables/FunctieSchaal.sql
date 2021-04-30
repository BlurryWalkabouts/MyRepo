CREATE TABLE [Dim].[FunctieSchaal]
(
	[FunctieSchaalKey]			INT					IDENTITY (1,1) NOT FOR REPLICATION,
	[MedewerkerKey]				INT					NOT NULL,		
	[DienstverbandKey]			INT					NOT NULL,
	[SchaalCode]				NVARCHAR(25)		NOT NULL,
	[Trede]						DECIMAL(4,1)		NOT NULL,
	[IsBovenschools]			BIT					NOT NULL,
	[BegindatumSalaris]			DATE				NULL,
	[EinddatumSalaris]			DATE				NULL,
	[FunctiePercentage]			DECIMAL(5,4)		NULL,
	[Salaris]					DECIMAL(10,3)		NULL,

	CONSTRAINT [PK_FunctieSchaal] PRIMARY KEY ([FunctieSchaalKey]),
	CONSTRAINT [FK_FunctieSchaal_DienstverbandKey] FOREIGN KEY ([DienstverbandKey]) REFERENCES [Dim].[Dienstverband]([DienstverbandKey]),
	CONSTRAINT [FK_FunctieSchaal_MedewerkerKey] FOREIGN KEY ([MedewerkerKey]) REFERENCES [Dim].Medewerker([MedewerkerKey]),
)