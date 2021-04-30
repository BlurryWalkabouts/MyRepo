CREATE TABLE [Dim].[ReportInfo]
(
	[Code]            INT             NOT NULL,
	[Name]            NVARCHAR (250)  NULL,
	[ReportName]      NVARCHAR (100)  NULL,
	[LandingPage]     NVARCHAR (4000) NULL,
	[PDF]             NVARCHAR (4000) NULL,
	[Word]            NVARCHAR (4000) NULL,
	[Logo]            NVARCHAR (100)  NULL,
	[EnableIncidents] TINYINT         NULL,
	[EnableChanges]   TINYINT         NULL,
	[EnableCalls]     TINYINT         NULL,
	CONSTRAINT [PK_ReportInfo] PRIMARY KEY CLUSTERED ([Code] ASC)
)