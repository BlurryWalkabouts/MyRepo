CREATE TABLE [Dim].[Ledger]
(
	[LedgerKey]   INT              IDENTITY (100000000, 1) NOT FOR REPLICATION,
	[unid]        UNIQUEIDENTIFIER NULL,
	[Text]        NVARCHAR (10)    NULL,
	[Description] NVARCHAR (30)    NULL,
	CONSTRAINT [PK_Ledger] PRIMARY KEY CLUSTERED ([LedgerKey])
)