CREATE VIEW [Dim].[vwDate]
AS

SELECT 
	DateKey
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
	, [Date]
	, WeekStartDate
	, WeekYear
	, DWMonthNumber
	, Holiday
	, DWWorkDayNumber
	, DayComparedToToday = DATEDIFF(DD, CAST(GETDATE() AS date), [Date])
	, WeekComparedToToday = DATEDIFF(WW, DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,-1,[Date]))
	, MonthComparedToToday = DATEDIFF(MM, CAST(GETDATE() AS date), [Date])
FROM
	Dim.[Date]