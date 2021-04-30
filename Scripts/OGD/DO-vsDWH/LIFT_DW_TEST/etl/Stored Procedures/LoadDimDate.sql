CREATE PROCEDURE [etl].[LoadDimDate]
AS
BEGIN

-- Test data: all dates, since this is procedurally generated anyway.

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.[Date]

INSERT INTO
	Dim.[Date]
	(
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
	)
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
FROM
	[$(LIFTDW)].Dim.[Date]

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END