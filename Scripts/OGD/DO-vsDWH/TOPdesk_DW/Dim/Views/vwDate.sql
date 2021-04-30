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
	, CalendarQuarter = 'Q' + CAST(CalendarQuarter AS char(1)) 
	, EN_MonthShort = LEFT(EN_Month,3)
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
	, MonthSelector = CONCAT(CalendarYear, '-', RIGHT('0' + CAST(MonthOfYear AS char(2)), 2))   
	, WeekSelector = CONCAT(CalendarYear, '-', RIGHT('0' + CAST(Weeknumber AS char(2)), 2)) 
	, DayComparedToToday = DATEDIFF(DD, CAST(GETDATE() AS date), [Date])
	, WeekComparedToToday = DATEDIFF(WW, DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,-1,[Date]))
	, MonthComparedToToday = DATEDIFF(MM, CAST(GETDATE() AS date), [Date])
FROM
	Dim.[Date]