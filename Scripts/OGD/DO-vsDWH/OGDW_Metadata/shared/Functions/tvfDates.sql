CREATE FUNCTION [shared].[tvfDates]
(
	@StartDate date
	, @EndDate date
)
RETURNS table
AS
RETURN

WITH Datums AS
(
SELECT
	[Date] = @StartDate
UNION ALL
SELECT
	[Date] = DATEADD(DD,1,[Date])
FROM
	Datums
WHERE
	[Date] < @EndDate
)

SELECT
	DateKey = CAST(REPLACE([Date],'-','') AS int)
	, [Date]
	, [DayOfWeek] = DATEPART(DW,[Date])
	, NL_Weekdag = CASE DATEPART(DW,[Date])
			WHEN 1 THEN 'maandag'
			WHEN 2 THEN 'dinsdag'
			WHEN 3 THEN 'woensdag'
			WHEN 4 THEN 'donderdag'
			WHEN 5 THEN 'vrijdag'
			WHEN 6 THEN 'zaterdag'
			WHEN 7 THEN 'zondag'
		END
	,EN_Weekday = CASE DATEPART(DW,[Date])
			WHEN 1 THEN 'Monday'
			WHEN 2 THEN 'Tuesday'
			WHEN 3 THEN 'Wednesday'
			WHEN 4 THEN 'Thursday'
			WHEN 5 THEN 'Friday'
			WHEN 6 THEN 'Saturday'
			WHEN 7 THEN 'Sunday'
		END
	, DayInMonth = DAY([Date])
	, [DayOfYear] = DATEPART(DAYOFYEAR,[Date])
	, WeekOfYear = DATEPART(WW,[Date])
	, Weeknumber = (DATEDIFF(DD,CASE
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY, 1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,[Date]),0))))/7)*7,-53690) <= [Date]
			THEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY, 1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,[Date]),0))))/7)*7,-53690)
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY, 0,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,[Date]),0))))/7)*7,-53690) <= [Date]
			THEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY, 0,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,[Date]),0))))/7)*7,-53690)
			ELSE DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY,-1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,[Date]),0))))/7)*7,-53690)
		END, [Date])/7) + 1
	, EN_Month = CASE MONTH([Date])
			WHEN 1 THEN 'January'
			WHEN 2 THEN 'February'
			WHEN 3 THEN 'March'
			WHEN 4 THEN 'April'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'June'
			WHEN 7 THEN 'July'
			WHEN 8 THEN 'August'
			WHEN 9 THEN 'September'
			WHEN 10 THEN 'October'
			WHEN 11 THEN 'November'
			WHEN 12 THEN 'December'
		END
	, NL_Maand = CASE MONTH([Date])
			WHEN 1 THEN 'januari'
			WHEN 2 THEN 'februari'
			WHEN 3 THEN 'maart'
			WHEN 4 THEN 'april'
			WHEN 5 THEN 'mei'
			WHEN 6 THEN 'juni'
			WHEN 7 THEN 'juli'
			WHEN 8 THEN 'augustus'
			WHEN 9 THEN 'september'
			WHEN 10 THEN 'oktober'
			WHEN 11 THEN 'november'
			WHEN 12 THEN 'december'
		END
	, MonthOfYear = MONTH([Date])
	, CalendarQuarter = CEILING((MONTH([Date])+2)/3)
	, CalendarYear = YEAR([Date])
	, DWDayNumber = DATEDIFF(DD,@StartDate,[Date]) + 1
	, CalendarSemester = CEILING((MONTH([Date])+5)/6)
	, DWWeekNumber = CASE
			WHEN DATEPART(DW,[Date]) = 7 THEN DATEDIFF(WW,@StartDate,[Date])
			ELSE DATEDIFF(WW,@StartDate,[Date]) + 1
		END
	, WeekStartYear = YEAR(DATEADD(DD,-1 * DATEPART(DW,[Date]) + 1,[Date]))
	, WeekStartDate = DATEADD(DD,-1 * DATEPART(DW,[Date]) + 1,[Date])
	, WeekYear = CASE
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY,1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,[Date]),0))))/7)*7,-53690) <= [Date] THEN YEAR([Date]) + 1
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY,0,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,[Date]),0))))/7)*7,-53690) <= [Date] THEN YEAR([Date])
			ELSE YEAR([Date]) - 1
		END
	, DWMonthNumber = DATEDIFF(MM,@StartDate,[Date]) + 1
FROM
	Datums