CREATE VIEW [Fact].[vwChangeActivityCountsPerDay]
AS

WITH FilteredChangeActivities AS
(
SELECT
	ActivityKey
	, DateCreation
	, DateTimeChangePhaseStart
	, DateTimePreviousActivityClosure
	, DateTimeStarted
	, DateClosure
	, DateTimePlannedStart
	, DateTimePlannedFinal
	, [Date]
FROM
	Dim.vwDate
	LEFT OUTER JOIN Fact.vwExtChangeActivity ON [Date] >= DateCreation AND ([Date] < DateClosure OR DateClosure IS NULL)
)

, StartDateCalculation AS
(
SELECT
	ActivityKey
	, [Date]
	, DateCalculatedStart = CAST(CASE
			WHEN DateTimeStarted IS NULL THEN COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart)
			WHEN DateTimeStarted >= COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart) THEN COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart)
			WHEN DateTimeStarted < COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart) THEN DateTimeStarted
		END AS date)
	, DateClosure
	, PlannedMinutes = DATEDIFF(MINUTE, DateTimePlannedStart, DateTimePlannedFinal)
FROM
	FilteredChangeActivities
)

, AgeCalculation AS
(
SELECT
	*
	, AgeMinutes = DATEDIFF(MINUTE, DateCalculatedStart, [Date])
	, AgeDays = DATEDIFF(DAY, DateCalculatedStart, [Date])
	, AgeWorkDays = dbo.DateDiffDays(DateCalculatedStart, [Date], 0, 0) -- No weekend and holidays
FROM
	StartDateCalculation
WHERE 1=1
	AND DateCalculatedStart <= [Date]
)

SELECT
	*
	, AgeVsPlannedDaysDelayBit = CASE
			WHEN PlannedMinutes > AgeMinutes THEN 0
			WHEN PlannedMinutes <= AgeMinutes THEN 1
			ELSE NULL
		END
FROM
	AgeCalculation