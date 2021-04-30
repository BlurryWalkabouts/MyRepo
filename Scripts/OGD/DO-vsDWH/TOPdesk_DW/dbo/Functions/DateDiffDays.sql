CREATE FUNCTION dbo.DateDiffDays
(
	@StartDate datetime
	, @EndDate datetime
	, @IncludeWeekend bit
	, @IncludeHoliday bit = 1
)
RETURNS int
AS
BEGIN

DECLARE @LastWeekday int
DECLARE @NrOfDays int

SELECT @LastWeekday = CASE WHEN @IncludeWeekend = 1 THEN 7 ELSE 5 END

SELECT
	@NrOfDays = COUNT(DateKey)
FROM
	Dim.[Date]
WHERE 1=1
	AND [Date] BETWEEN DATEADD(DD,1,@StartDate) AND @EndDate
	AND [DayOfWeek] <= @LastWeekday
	AND Holiday <= @IncludeHoliday

RETURN (@NrOfDays)

END

/*
SELECT dbo.DateDiffDays('20150201','20150207',1)
*/