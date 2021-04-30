CREATE TABLE [Dim].[Project]
(
	[ProjectKey]          INT              NOT NULL,
	[unid]                UNIQUEIDENTIFIER NULL,
	[ProjectNumber]       NVARCHAR (20)    NULL,
	[ProjectName]         NVARCHAR (70)    NOT NULL,
	[CustomerKey]         INT              NOT NULL,
	[OperatorKey]         INT              NOT NULL,
	[ProductGroup]        NVARCHAR (30)    NOT NULL,
	[Product]             NVARCHAR (30)    NOT NULL,
	[ProjectGroupNumber]  NVARCHAR (30)    NULL,
	[ProjectGroupName]    NVARCHAR (70)    NULL,
	[ProjectStatus]       INT              NULL,
	[ProjectStartDate]    DATE             NULL,
	[ProjectEndDate]      DATE             NULL,
	[ProjectCreationDate] DATE             NULL,
	[ProjectChangeDate]   DATE             NULL,
	[ProjectAcceptDate]   DATE             NULL,
	[ProjectArchiveDate]  DATE             NULL,
	[Office]              NVARCHAR (40)    NULL,
	[SalesTarget]         MONEY            NULL,
	[ProjectPrice]        MONEY            NULL,
	CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([ProjectKey] ASC)
)