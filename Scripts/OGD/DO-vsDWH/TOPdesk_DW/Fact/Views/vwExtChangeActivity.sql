CREATE VIEW [Fact].[vwExtChangeActivity]
AS

WITH FilteredChangeActivities AS
(
SELECT 
	ActivityKey = ChangeActivity_Id
	, ChangeKey
	, OperatorGroupKey
	, ActivityNumber
	, DateCreation = CreationDate
	, DateTimeCreation = CAST(CreationDate AS datetime) + CAST(CreationTime AS datetime)
	, BriefDescription
	, ActivityTemplate
  	, ChangePhaseName = CASE
			WHEN ChangePhase = 2 THEN 'Request'
			WHEN ChangePhase = 5 THEN 'Progress'
			WHEN ChangePhase = 6 THEN 'Evaluation'
			ELSE 'Unknown'
		END
	, ChangePhaseNumber = ChangePhase
	, [Level]
	, PlannedStartRank
	, DateChangePhaseStart = CAST(ChangePhaseStartDate AS DATE)
	, DateTimeChangePhaseStart = ChangePhaseStartDate
	, MayStart
	, [Started]
	, DateStarted = StartedDate
	, DateTimeStarted = CAST(StartedDate AS datetime) + CAST(StartedTime AS datetime)
	, DatePlannedStart = PlannedStartDate
	, DateTimePlannedStart = CAST(PlannedStartDate AS datetime) + CAST(PlannedStartTime AS datetime)
	, Skipped
	, DateSkipped = SkippedDate
	, DateTimeSkipped = CAST(SkippedDate AS datetime) + CAST(SkippedTime AS datetime)
	, Resolved
	, DateResolved = ResolvedDate
	, DateTimeResolved = CAST(ResolvedDate AS datetime) + CAST(ResolvedTime AS datetime)
	, DatePreviousActivityClosure = LAG(ClosureDate) OVER (PARTITION BY ChangeKey ORDER BY ChangePhase, [Level], PlannedStartRank, ActivityNumber)
	-- Move logic to DWH
	, DateTimePreviousActivityClosure = LAG(CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime)) OVER (PARTITION BY ChangeKey ORDER BY ChangePhase, [Level], PlannedStartRank, MayStart, [Started], ClosureDate, ClosureTime, ActivityNumber)
	, Closed
	, DateClosure = ClosureDate
	, DateTimeClosure = CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime)
	, DatePlannedFinal = PlannedFinalDate
	, DateTimePlannedFinal = CAST(PlannedFinalDate AS datetime) + CAST(PlannedFinalTime AS datetime)
	, DateLastChanged = ChangeDate
	, DateTimeLastChanged = CAST(ChangeDate AS datetime) + CAST(ChangeTime AS datetime)
	, TimeTaken
	-- Move logic to DWH
	, Ranking = RANK() OVER (PARTITION BY ChangeKey ORDER BY ChangePhase, [Level], PlannedStartRank, MayStart, [Started], ClosureDate, ClosureTime, ActivityNumber)
FROM
	Fact.ChangeActivity CA
	INNER JOIN Dim.Customer CU ON CU.CustomerKey = CA.CustomerKey AND CU.SysAdminTeam <> 'Geen'
)

-- Move logic to DWH
, StartDateTimeCalculation AS
(
SELECT
	*
	, DateTimeCalculatedStart = CAST(CASE
			WHEN DateTimeStarted IS NULL THEN COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart)
			WHEN DateTimeStarted >= COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart) THEN COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart)
			WHEN DateTimeStarted < COALESCE(DateTimePreviousActivityClosure, DateTimeChangePhaseStart) THEN DateTimeStarted
		END AS datetime)
FROM 
	FilteredChangeActivities
)

, AgeCalculation AS
(
SELECT
	*
	, PlannedMinutes = DATEDIFF(MINUTE, DateTimePlannedStart, DateTimePlannedFinal)
	, AgeMinutes = DATEDIFF(MINUTE, DateTimeCalculatedStart, COALESCE(DateTimeClosure, GETUTCDATE()))
	, AgeDays = DATEDIFF(DAY, DateTimeCalculatedStart, COALESCE(DateTimeClosure, GETUTCDATE()))
	, AgeWorkDays = dbo.DateDiffDays(DateTimeCalculatedStart, COALESCE(DateTimeClosure, GETUTCDATE()),0,0) -- No weekend and holidays
FROM 
	StartDateTimeCalculation
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