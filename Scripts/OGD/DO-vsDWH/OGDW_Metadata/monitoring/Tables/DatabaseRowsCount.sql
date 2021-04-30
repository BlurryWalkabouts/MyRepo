CREATE TABLE [monitoring].[DatabaseRowsCount]
(
	[DatabaseRowsCountID] INT          IDENTITY (1,1) NOT FOR REPLICATION,
	[MonitoringDate]      DATETIME     NOT NULL,
	[Fact]                VARCHAR (16) NOT NULL,
	[DatabaseName]        VARCHAR (16) NOT NULL,
	[SourceDatabaseKey]   INT          NOT NULL,
	[RowsCount]           INT          NOT NULL,
	CONSTRAINT [PK_DatabaseRowsCount] PRIMARY KEY CLUSTERED ([DatabaseRowsCountID] ASC)
)