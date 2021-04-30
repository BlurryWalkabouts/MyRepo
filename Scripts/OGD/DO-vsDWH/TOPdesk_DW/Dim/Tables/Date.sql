CREATE TABLE [Dim].[Date]
(
	[DateKey]          INT          NOT NULL,
	[Date]             DATE         NOT NULL,
	[DayOfWeek]        SMALLINT     NULL,
	[NL_Weekdag]       VARCHAR (10) NULL,
	[EN_Weekday]       VARCHAR (10) NULL,
	[DayInMonth]       SMALLINT     NULL,
	[DayOfYear]        SMALLINT     NULL,
	[WeekOfYear]       TINYINT      NULL,
	[Weeknumber]       TINYINT      NULL,
	[EN_Month]         VARCHAR (10) NULL,
	[NL_Maand]         VARCHAR (10) NULL,
	[MonthOfYear]      TINYINT      NULL,
	[CalendarQuarter]  TINYINT      NULL,
	[CalendarYear]     SMALLINT     NULL,
	[DWDayNumber]      SMALLINT     NULL,
	[CalendarSemester] TINYINT      NULL,
	[DWWeekNumber]     SMALLINT     NULL,
	[NL_WeekdayShort]  AS           CONVERT(char(2), LEFT(NL_Weekdag,(2))) PERSISTED,
	[NL_MonthShort]    AS           CONVERT(char(3), LEFT(NL_Maand,(3))) PERSISTED,
	[WeekStartYear]    SMALLINT     NULL,
	[WeekStartDate]    DATE         NULL,
	[WeekYear]         SMALLINT     NULL,
	[DWMonthNumber]    SMALLINT     NULL,
	[Holiday]          BIT          NULL,
	[DWWorkDayNumber]  SMALLINT     DEFAULT 0 NULL,
	[EN_WeekdayShort]  AS           CONVERT(char(2), LEFT(EN_Weekday,(2))) PERSISTED,
	[EN_MonthShort]    AS           CONVERT(char(3), LEFT(EN_Month,(3))) PERSISTED,
	[DayDiffToToday]   AS           DATEDIFF(DD, CONVERT(date,GETUTCDATE()), [Date]),
	[WeekDiffToToday]  AS           CONVERT(smallint, DATEDIFF(WW, DATEADD(DD,-1,GETUTCDATE()), DATEADD(DD,-1,[Date]))),
	[MonthDiffToToday] AS           CONVERT(smallint, DATEDIFF(MM, CONVERT(date,GETUTCDATE()), [Date])),
	[MonthSelector]    AS           CONVERT(char(7), NULLIF(CONCAT(CalendarYear, '-', RIGHT(CONCAT('0',MonthOfYear),(2))),'-1-0')) PERSISTED,
	[WeekSelector]     AS           CONVERT(char(7), NULLIF(CONCAT(WeekStartYear, '-', RIGHT(CONCAT('0',Weeknumber),(2))),'-0')) PERSISTED,
	CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED ([Date] ASC)
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Date_]
	ON [Dim].[Date] ([Date] ASC)
	INCLUDE ([WeekOfYear], [Weeknumber], [WeekYear])
GO

CREATE NONCLUSTERED INDEX [IX_DimDate_Date]
	ON [Dim].[Date] ([Date] ASC)
	INCLUDE ([DateKey], [DayOfWeek], [DWWeekNumber], [DWMonthNumber])
GO

CREATE NONCLUSTERED INDEX [IX_Date_Metadata]
	ON [Dim].[Date] ([Date] ASC)
	INCLUDE ([DateKey], [Weeknumber], [MonthOfYear], [CalendarYear], [DWWeekNumber], [NL_MonthShort], [WeekYear], [DWMonthNumber])
GO