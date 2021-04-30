CREATE TABLE [monitoring].[ReportServerCatalog]
(
	[ID]                    INT              IDENTITY (1,1) NOT FOR REPLICATION,
	[ItemID]                UNIQUEIDENTIFIER NOT NULL,
	[Name]                  NVARCHAR (425)   NOT NULL,
	[Path]                  NVARCHAR (425)   NOT NULL,
	[Description]           NVARCHAR (MAX)   NULL,
	[Type]                  INT              NOT NULL,
	[TypeDescription]       NVARCHAR (32)    NOT NULL,
	[OriginalReportName]    NVARCHAR (425)   NULL,
	[OriginalReportPath]    NVARCHAR (425)   NULL,
	[ReportPartComponentID] UNIQUEIDENTIFIER NULL,
	[CreationDate]          DATETIME         NULL,
	[CreatedBy]             NVARCHAR (260)   NULL,
	[ChangeDate]            DATETIME         NULL,
	[ChangedBy]             NVARCHAR (260)   NULL,
	[ContentXML]            XML              NULL,
	[CommandType]           NVARCHAR (32)    NOT NULL,
	[CommandText]           NVARCHAR (MAX)   NULL,
	[Parameter]             XML              NULL
)
GO

CREATE UNIQUE CLUSTERED INDEX [CI_ReportServerCatalog]
	ON [monitoring].[ReportServerCatalog] ([ID] ASC)
GO
/*
CREATE FULLTEXT INDEX
	ON [monitoring].[ReportServerCatalog] (ContentXML Language 1033) KEY INDEX [CI_ReportServerCatalog] ON [Default Catalog]
GO
*/