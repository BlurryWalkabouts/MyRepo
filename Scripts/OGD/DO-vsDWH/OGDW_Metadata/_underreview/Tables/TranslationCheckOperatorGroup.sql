CREATE TABLE [monitoring].[TranslationCheckOperatorGroup]
(
	[SourceDatabaseKey]  INT            NULL,
	[OperatorGroup]      NVARCHAR (93)  NULL,
	[OperatorGroupSTD]   NVARCHAR (100) NULL,
	[OperatorGroupSTDTT] INT            NOT NULL
)