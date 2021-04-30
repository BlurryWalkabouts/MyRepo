CREATE TABLE [Fact].[WorkforceResourcesPerDay]
(
	[WorkforceResourcesPerDayKey] INT             IDENTITY (1,1) NOT FOR REPLICATION,
	[Date]                        DATETIME2 (3)   NULL,
	[CustomerGroup]               NVARCHAR (250)  NULL,
	[Hours]                       DECIMAL (10, 2) NULL,
	CONSTRAINT [PK_WorkforceResourcesPerDay] PRIMARY KEY CLUSTERED ([WorkforceResourcesPerDayKey] ASC)
)