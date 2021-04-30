CREATE PROCEDURE [Load].[LoadDimDate]
(
	@WriteLog bit = 1
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @MaxDate date = (SELECT MAX([Date]) FROM Dim.[Date])

IF @MaxDate < DATEFROMPARTS(YEAR(DATEADD(YY,3,SYSUTCDATETIME())),12,31) OR @MaxDate IS NULL
BEGIN

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM Dim.[Date]

PRINT 'Inserting unknowns into Dim.Date'
INSERT INTO
	Dim.[Date] (DateKey, [Date], [DayOfWeek], DayInMonth, CalendarYear, DWDayNumber)
VALUES
	(-1, '1753-01-01', -1, -1, -1, -1)

SET DATEFIRST 1

DECLARE @StartDate date = DATEFROMPARTS(2010,1,1)
DECLARE @EndDate date = DATEFROMPARTS(YEAR(DATEADD(YY,3,SYSUTCDATETIME())),12,31)

PRINT 'Inserting data into Dim.Date'
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
	, WeekStartYear
	, WeekStartDate
	, WeekYear
	, DWMonthNumber
	, Holiday
	)
SELECT
	d.DateKey
	, d.[Date]
	, d.[DayOfWeek]
	, d.NL_Weekdag
	, d.EN_Weekday
	, d.DayInMonth
	, d.[DayOfYear]
	, d.WeekOfYear
	, d.Weeknumber
	, d.EN_Month
	, d.NL_Maand
	, d.MonthOfYear
	, d.CalendarQuarter
	, d.CalendarYear
	, d.DWDayNumber
	, d.CalendarSemester
	, d.DWWeekNumber
	, d.WeekStartYear
	, d.WeekStartDate
	, d.WeekYear
	, d.DWMonthNumber
	, d2.Holiday
FROM
	[Load].tvfDates(@StartDate,@EndDate) d
    LEFT OUTER JOIN mdm.DimDate d2 ON d.DateKey = d2.Code
OPTION (MAXRECURSION 0)

SET @newRowCount += @@ROWCOUNT

;WITH sub AS
(
SELECT
	D1.DateKey 
	, RN = COUNT(D2.DateKey)
FROM
	Dim.[Date] D1
	INNER JOIN Dim.[Date] D2 ON D1.DateKey >= D2.DateKey AND D2.Holiday = 0 AND D2.[DayOfWeek] < 6
GROUP BY
	D1.DateKey
)

UPDATE
	D
SET
	D.DWWorkDayNumber = sub.RN
FROM
	Dim.[Date] D
	INNER JOIN sub ON D.DateKey = sub.DateKey

COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END

/*
SELECT
	DateKey
	, Workday = CASE WHEN Holiday = 0 AND DayOfWeek < 6 THEN 1 ELSE 0 END
	, RN = ROW_NUMBER() OVER (PARTITION BY CASE WHEN Holiday = 0 AND DayOfWeek < 6 THEN 1 ELSE 0 END ORDER BY DWDayNumber)
FROM
	Dim.[Date]
*/

END