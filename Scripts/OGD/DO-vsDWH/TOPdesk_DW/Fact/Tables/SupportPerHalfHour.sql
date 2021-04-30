CREATE TABLE [Fact].[SupportPerHalfHour]
(
	[SupportWindowKey] TINYINT NOT NULL,
	[DayOfWeek]        TINYINT NOT NULL,
	[half_hour_of_day] TINYINT NOT NULL,
	[Support]          BIT     NULL,
	CONSTRAINT [PK_SupportPerHalfHour] PRIMARY KEY CLUSTERED ([SupportWindowKey] ASC, [DayOfWeek] ASC, [half_hour_of_day] ASC)
)