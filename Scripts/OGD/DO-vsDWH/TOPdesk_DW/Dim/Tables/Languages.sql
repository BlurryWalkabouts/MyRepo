CREATE TABLE [Dim].[Languages]
(
	[LanguagesKey]      INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[Language]          NVARCHAR (100) NULL,
	[Locale]            NVARCHAR (100) NULL,
	[Code]              INT            NULL,
	[MainLanguage_Code] INT            NULL,
	CONSTRAINT [PK_Languages] PRIMARY KEY CLUSTERED ([LanguagesKey] ASC)
)