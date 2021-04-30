CREATE TABLE [Fact].[SupportWindowPerHalfHour]
(
	[SupportWindowID]  SMALLINT NOT NULL,
	[Datetime]         DATETIME NOT NULL,
	[TimeStamp]        INT      NOT NULL,
	[Half_hour_of_day] INT      NOT NULL,
	[Support]          TINYINT  NOT NULL,
	[SupportedRN]      INT      NULL,
	[TotalRN]          BIGINT   NULL,
	CONSTRAINT [PK_SupportWindowPerHalfHour] PRIMARY KEY CLUSTERED ([SupportWindowID] ASC, [TimeStamp] ASC)
)
GO

CREATE NONCLUSTERED INDEX [IX_SupportWindowPerHalfHour_TimeStamp]
	ON [Fact].[SupportWindowPerHalfHour] ([SupportWindowID] ASC, [TimeStamp] ASC)
	INCLUDE ([SupportedRN])
GO