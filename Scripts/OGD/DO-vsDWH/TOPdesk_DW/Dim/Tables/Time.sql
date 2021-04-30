CREATE TABLE [Dim].[Time]
(
	[TimeKey]               INT            NOT NULL,
	[Minute_of_day]         INT            NULL,
	[Hour_of_day_24]        DECIMAL (38)   NULL,
	[Hour_of_day_12]        DECIMAL (38)   NULL,
	[AM_PM]                 NVARCHAR (100) NULL,
	[Minute_of_hour]        DECIMAL (38)   NULL,
	[Half_hour]             DECIMAL (38)   NULL,
	[Half_hour_of_day]      DECIMAL (38)   NULL,
	[Quarter_hour]          DECIMAL (38)   NULL,
	[Quarter_hour_of_day]   DECIMAL (38)   NULL,
	[Time_half_hour_of_day] TIME (0)       NULL,
	[Time]                  TIME (0)       NULL,
	CONSTRAINT [PK_Time] PRIMARY KEY CLUSTERED ([TimeKey] ASC)
)
GO

CREATE NONCLUSTERED INDEX [IX_TimeKey_Half_hour_of_day]
	ON [Dim].[Time] ([Time] ASC)
	INCLUDE ([TimeKey], [Half_hour_of_day])
GO