CREATE VIEW [Dim].[vwDateTimeHalfHours]
AS

SELECT
	DateKey
	, [Date]
	, [DayOfWeek]
	, NL_Weekdag
	, EN_Weekday
	, DayInMonth
	, [DayOfYear]
	, WeekOfYear
	, Weeknumber
	, EN_Month
	, NL_Maand
	, MonthOfYear
	, CalendarQuarter
	, CalendarYear
	, DWDayNumber
	, CalendarSemester
	, DWWeekNumber
	, NL_WeekdayShort
	, NL_MonthShort
	, WeekStartYear
	, WeekStartDate
	, WeekYear
	, DWMonthNumber
	, Holiday
	, DWWorkDayNumber
	, EN_WeekdayShort
	, EN_MonthShort
	, DayDiffToToday
	, WeekDiffToToday
	, MonthDiffToToday
	, MonthSelector
	, WeekSelector
	, TimeKey
	, Minute_of_day
	, Hour_of_day_24
	, Hour_of_day_12
	, AM_PM
	, Minute_of_hour
	, Half_hour
	, Half_hour_of_day
	, Quarter_hour
	, Quarter_hour_of_day
	, Time_half_hour_of_day
	, [Time]
FROM
	Dim.[Date]
	CROSS JOIN Dim.[Time]
WHERE 1=1
	AND [Time] IS NOT NULL
	AND DATEPART(MI,[Time]) % 30 = 0
	AND DATEPART(SS,[Time]) = 0