CREATE TABLE [Dim].[ReportLabels]
(
	[LanguageCode] INT             NOT NULL,
	[Language]     NVARCHAR (100)  NOT NULL,
	[Locale]       NVARCHAR (100)  NOT NULL,
	[Name]         NVARCHAR (250)  NOT NULL,
	[Code]         INT             NOT NULL,
	[Translation]  NVARCHAR (1000) NOT NULL,
	CONSTRAINT [PK_ReportLabels] PRIMARY KEY ([LanguageCode], [Name])
)