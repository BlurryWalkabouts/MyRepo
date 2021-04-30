CREATE VIEW [Fact].[vwExtChange]
AS

WITH FilteredChanges AS
(
SELECT DISTINCT
	ResponsibilityOGD = CASE
			-- If MKBO, assume OGD is responsible
			WHEN SysAdminTeam IN ('MKBO', 'IA') THEN 1
			WHEN CH.CustomerKey IN (44, 258) AND Category IN ('Kantoorautomatisering') THEN 1
			WHEN Coordinator IN ('Loo, Michel van de', 'SSD OGD', 'SERVICEDESK', 'Dompeling, Alex', 'WIJZIGINGSCOÖRDINATIE', 'Frank Smulders', 'Lustenhouwer, Sander') THEN 1
			WHEN SysAdminTeam = 'Alpha' THEN 1
			ELSE 0
		END
	, CU.CustomerKey
	, ChangeKey = Change_Id
	, ChangeNumber
	, [ChangeFinances] = CONCAT(CU.DebitNumber,'-',ChangeNumber)
	, Category
	, Subcategory
	, DescriptionBrief
	, DescriptionBriefContains = CASE	
			WHEN DescriptionBrief LIKE '%Hardware%' OR DescriptionBrief LIKE '%Laptop%' THEN 'Hardware'
			WHEN DescriptionBrief LIKE '%Account%' OR DescriptionBrief LIKE '%Gebruiker%' THEN 'Account'
			WHEN DescriptionBrief LIKE '%Auth%' OR DescriptionBrief LIKE '%Rechten%' THEN 'Right'
			WHEN DescriptionBrief LIKE '%Software%' OR DescriptionBrief LIKE '%Applicatie%' THEN 'Software'
			WHEN DescriptionBrief LIKE '%Mail%' OR DescriptionBrief LIKE 'Exchange' THEN 'Mail'
			ELSE 'Other'
		END
	, OriginalIncident
	, CancelledByOperator
	, ChangeType
	, [Type]
	, TypeSTD
	, Template
	, Coordinator
	, CurrentPhaseSTD

	, Evaluation
	, Implemented
	, Rejected
	, [Started]
	, Closed

	, DateRequest = RequestDate
	, DateCreation = CreationDate
	, DateSubmissionRequestChange = SubmissionDateRequestChange
	, DateAuthorization = AuthorizationDate
	, DateImplExtChange = ImplDateExtChange
	, DateEndExtChange = EndDateExtChange
	, DatePlannedAuthorization = PlannedAuthDateRequestChange
	, DatePlannedImpl = PlannedImplDate
	, DatePlannedFinal = PlannedFinalDate
	, DateNoGoExtChange = NoGoDateExtChange
	, DateCancelExtChange = CancelDateExtChange
	, DateRejection = RejectionDate
	, DateCompletion = CompletionDate
	, DateClosure = ClosureDate
	, DateLastChanged = ChangeDate
	, DateTimeRequest = CAST(RequestDate AS datetime) + CAST(RequestTime AS datetime)
	, DateTimeCreation = CAST(CreationDate AS datetime) + CAST(CreationTime AS datetime)
	, DateTimeSubmissionRequestChange = CAST(SubmissionDateRequestChange AS datetime) + CAST(SubmissionTimeRequestChange AS datetime)
	, DateTimeAuthorization = CAST(AuthorizationDate AS datetime) + CAST(AuthorizationTime AS datetime)
	, DateTimeImplExtChange = CAST(ImplDateExtChange AS datetime) + CAST(ImplTimeExtChange AS datetime)
	, DateTimeEndExtChange = CAST(EndDateExtChange AS datetime) + CAST(EndTimeExtChange AS datetime)
	, DateTimeNoGoExtChange = CAST(NoGoDateExtChange AS datetime) + CAST(NoGoTimeExtChange AS datetime)
	, DateTimeCancelExtChange = CAST(CancelDateExtChange AS datetime) + CAST(CancelTimeExtChange AS datetime)
	, DateTimeRejection = CAST(RejectionDate AS datetime) + CAST(RejectionTime AS datetime)
	, DateTimePlannedAuthorization = CAST(PlannedAuthDateRequestChange AS datetime) + CAST(PlannedAuthTimeRequestChange AS datetime)
	, DateTimePlannedImpl = CAST(PlannedImplDate AS datetime) + CAST(PlannedImplTime AS datetime)
	, DateTimePlannedFinal = CAST(PlannedFinalDate AS datetime) + CAST(PlannedFinalTime AS datetime)
	, DateTimeCompletion = CAST(CompletionDate AS datetime) + CAST(CompletionTime AS datetime)
	, DateTimeClosure = CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime)
	, DateTimeLastChanged = CAST(ChangeDate AS datetime) + CAST(ChangeTime AS datetime)
--	, Ranking = DENSE_RANK() OVER (Partition by Change_ID ORDER BY ChangeDate DESC)
FROM 
	Fact.[Change] CH
	INNER JOIN Dim.Customer CU ON (CU.CustomerKey = CH.CustomerKey AND CU.SysAdminTeam <> 'Geen')
WHERE 1=1
	AND DescriptionBrief NOT LIKE 'Oud wijzigingsnummer: W %'
)
--SELECT * FROM FilteredChanges
--WHERE DateFinished IS NOT NULL

, ChangeCalculation AS
(
SELECT
	FC.*
	, AgeRankingOverall = DENSE_RANK() OVER (ORDER BY DateTimeCreation, ChangeNumber)
	, AgeRankingPerResponsibilityOGD = DENSE_RANK() OVER (PARTITION BY ResponsibilityOGD ORDER BY DateTimeCreation, ChangeNumber)
	-- Logic to determine if a change is OGD or Non-OGD
	-- Ranking to filter out OGD DB anomalies
	, ChangeFinances_Ranking = DENSE_RANK() OVER (PARTITION BY Changefinances ORDER BY DateTimeCreation DESC)
		
	, AgeWorkDays = AgeWorkDays.NumberOfDays -- No weekend and holidays
	, AgeDays
	, AvgAgeWorkDays = AVG(AgeWorkDays.NumberOfDays) OVER ()
	, AvgDays = AVG(AgeDays.AgeDays) OVER()

	-- RequestPhase
	, PlannedAuthVsAuthorizationDiffDay = DATEDIFF(DAY, DatePlannedAuthorization, COALESCE(DateAuthorization, DateCompletion, GETUTCDATE()))
	, PlannedAuthorizationDelayBit = CASE	
			WHEN DATEDIFF(DAY, DateTimePlannedAuthorization, COALESCE(DateTimeAuthorization, DateCompletion, GETUTCDATE())) <= 0 THEN 0
			WHEN DATEDIFF(DAY, DateTimePlannedAuthorization, COALESCE(DateTimeAuthorization, DateCompletion, GETUTCDATE())) > 0 THEN 1
			ELSE NULL
		END

	-- ProgressPhase
	, PlannedImplVsCompletionDiffDay = DATEDIFF(DAY, DateTimePlannedImpl, COALESCE(DateTimeCompletion, GETUTCDATE()))
	, PlannedImplementationDelayBit = CASE
			WHEN DATEDIFF(DAY, DateTimePlannedImpl, COALESCE(DateTimeCompletion, GETUTCDATE())) <= 0 THEN 0
			WHEN DATEDIFF(DAY, DateTimePlannedImpl, COALESCE(DateTimeCompletion, GETUTCDATE())) > 0 THEN 1
			ELSE NULL
		END

	-- EvaluationPhase
	, PlannedFinalVsClosureDiffDay = DATEDIFF(DAY, DateTimePlannedFinal, COALESCE(DateTimeClosure, GETUTCDATE()))
	, PlannedFinalDelayBit = CASE
			WHEN DATEDIFF(DAY, DateTimePlannedFinal, COALESCE(DateTimeClosure, GETUTCDATE())) <= 0 THEN 0
			WHEN DATEDIFF(DAY, DateTimePlannedFinal, COALESCE(DateTimeClosure, GETUTCDATE())) > 0 THEN 1
			ELSE NULL
		END
FROM 
	FilteredChanges FC
	CROSS APPLY (SELECT NumberOfDays = dbo.DateDiffDays(DateCreation, COALESCE(DateCompletion,GETUTCDATE()),0,0)) AgeWorkDays
	CROSS APPLY (SELECT AgeDays = DATEDIFF(DAY, DateCreation, COALESCE(DateCompletion,GETUTCDATE()))) AgeDays
)
--SELECT * FROM ChangeCalculation

/* Count ActivityInfo per change */
, ChangeActivityCount AS
(
SELECT
	CA.ChangeKey
	, ActivityCount = COUNT(ChangeActivity_Id)
	, ActivityApprovedCount = SUM(CAST(Approved AS int))
	, ActivityMayStartCount = SUM(CAST(MayStart AS int))
	, ActivityStartedCount = SUM(CAST(CA.Started AS int))
	, ActivitySkippedCount = SUM(CAST(Skipped AS int))
	, ActivityRejectedCount = SUM(CAST(CA.Rejected AS int))
	, ActivityResolvedCount = SUM(CAST(Resolved AS int))
	, ActivityToGoCount = COUNT(*) - SUM(CAST(Resolved AS int)) - SUM(CAST(Skipped AS int)) - SUM(CAST(CA.Rejected AS int))
	, PercentageOfActivitysCompleted = SUM((CAST(Resolved AS int)) + CAST(Skipped AS int) + CAST(CA.Rejected AS int)) * 1. / COUNT(*)
FROM
	Fact.ChangeActivity CA
	INNER JOIN FilteredChanges FC ON CA.ChangeKey = FC.ChangeKey
GROUP BY
	CA.ChangeKey
)
--SELECT * FROM ChangeActivityCount

, FilteredChangeActivity AS
(
SELECT
	CA.ChangeKey
	, ActivityOperatorGroupSTD = OperatorGroupSTD
	, ActivityPlannedStartRank = PlannedStartRank
	, ActivityLevel = [Level]
	, ActivityChangePhaseNumber = ChangePhase
	, ActivityChangePhaseName = CASE ChangePhase
		 	WHEN 2 THEN 'Request'
		 	WHEN 5 THEN 'Progress'
		 	WHEN 6 THEN 'Evaluation'
		 	ELSE 'Unknown'
		END
	, ActivityNumber
	, ActivityBriefDescription = BriefDescription
	, ActivityApproved = Approved
	, ActivityMayStart = MayStart
	, ActivityStarted = CA.[Started]
	, ActivityResolved = Resolved
	, ActivitySkipped = Skipped
	, ActivityRejected = CA.Rejected
	, DateActivityCreation = CreationDate
	-- Move logic to Fact.ChangeActivity [MaxPreviousActivityEndDate]
	, DateActivityPreviousClosure = LAG(ClosureDate) OVER (PARTITION BY CA.ChangeKey ORDER BY ChangePhase, [Level], PlannedStartRank, MayStart, CA.[Started], ClosureDate, ClosureTime, ActivityNumber)
	, DateActivityStarted = StartedDate
	, DateActivityClosure = ClosureDate
	, DateActivityLastChanged = ChangeDate
	, DateActivityPlannedStart = PlannedStartDate
	, DateActivityPlannedEnd = PlannedFinalDate
	, DateTimeActivityCreation = CAST(CreationDate AS datetime) + CAST(CreationTime AS datetime)
	, DateTimeChangePhaseStart = ChangePhaseStartDate
	-- Move logic to Fact.ChangeActivity [MaxPreviousActivityEndDate]
	, DateTimeActivityPreviousClosure = LAG(CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime)) OVER (PARTITION BY CA.ChangeKey ORDER BY ChangePhase, [Level], PlannedStartRank, MayStart, CA.[Started], ClosureDate, ClosureTime, ActivityNumber)
	, DateTimeActivityStarted = CAST(StartedDate AS datetime) + CAST(StartedTime AS datetime)
	, DateTimeActivityClosure = CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime)
	, DateTimeActivityLastChanged = CAST(ChangeDate AS datetime) + CAST(ChangeTime AS datetime)
	, DateTimeActivityPlannedStart = CAST(CA.PlannedStartDate AS datetime) + CAST(CA.PlannedStartDate AS datetime)
	, DateTimeActivityPlannedEnd = CAST(CA.PlannedFinalDate AS datetime) + CAST(CA.PlannedFinalDate AS datetime)
	--Move logic to DWH
	, ActivityRanking = RANK() OVER (PARTITION BY CA.ChangeKey ORDER BY ChangePhase, [Level], PlannedStartRank, MayStart, CA.[Started], ClosureDate, ClosureTime, ActivityNumber)
FROM Fact.ChangeActivity CA
	INNER JOIN FilteredChanges FC ON CA.ChangeKey = FC.ChangeKey
	INNER JOIN Dim.OperatorGroup OG ON (OG.OperatorGroupKey = CA.OperatorGroupKey)
)
--SELECT * FROM FilteredChangeActivity

-- Move logic to DWH
, StartDateCalculation AS
(
SELECT
	*
	, DateTimeActivityCalculatedStart = CAST(CASE
			WHEN DateTimeActivityStarted IS NULL THEN COALESCE(DateTimeActivityPreviousClosure, DateTimeChangePhaseStart)
			WHEN DateTimeActivityStarted >= COALESCE(DateTimeActivityPreviousClosure, DateTimeChangePhaseStart) THEN COALESCE(DateTimeActivityPreviousClosure, DateTimeChangePhaseStart)
			WHEN DateTimeActivityStarted < COALESCE(DateTimeActivityPreviousClosure, DateTimeChangePhaseStart) THEN DateTimeActivityStarted
		END AS datetime)
FROM 
	FilteredChangeActivity
)

, ChangeActivityCalculation AS
(
SELECT
	SDC.*
	, ActivityWaitingWorkDays = Waiting.NumberOfDays
	, ActivityWaitingDays = DATEDIFF(DAY, DateTimeActivityCreation , COALESCE(DateTimeActivityClosure, GETUTCDATE()))
	, ActivityAgeWorkDays = Age.NumberOfDays 
	, ActivityAgeDays = DATEDIFF(DAY, DateTimeActivityCalculatedStart, COALESCE(DateTimeActivityClosure, GETUTCDATE()))
	, ActivityAgeMinutes = DATEDIFF(MINUTE, DateTimeActivityCalculatedStart, COALESCE(DateTimeActivityClosure, GETUTCDATE()))
	, ActivityPlannedDays = DATEDIFF(DAY, DateTimeActivityPlannedStart, DateTimeActivityPlannedEnd)
	, ActivityPlannedMinutes = DATEDIFF(MINUTE, DateTimeActivityPlannedStart, DateTimeActivityPlannedEnd)
	-- Compare ActivityAgeDays with ActivityPlannedDays
	, ActivityAgeVsPlannedDiffInDays = DATEDIFF(DAY, DateTimeActivityCalculatedStart, COALESCE(DateTimeActivityClosure, GETUTCDATE())) - DATEDIFF(DAY, DateTimeActivityPlannedStart, DateTimeActivityPlannedEnd)
	-- Compare ActivityAgeMinutes with ActivityPlannedMinutes
	, ActivityAgeVsPlannedDiffInMinute = DATEDIFF(MINUTE, DateTimeActivityCalculatedStart, COALESCE(DateTimeActivityClosure, GETUTCDATE())) - DATEDIFF(MINUTE, DateTimeActivityPlannedStart, DateTimeActivityPlannedEnd)
	-- Ranking here to ensure we only get 1 result. Might need to fix this at a later date
	, ActivityStartedRanking = DENSE_RANK() OVER (Partition by ChangeKey ORDER BY DateActivityStarted DESC, ActivityRanking)
FROM
	StartDateCalculation SDC
	CROSS APPLY (SELECT NumberOfDays = dbo.DateDiffDays(SDC.DateTimeActivityCalculatedStart, COALESCE(DateTimeActivityClosure, GETUTCDATE()),0,0)) Age
	CROSS APPLY (SELECT NumberOfDays = dbo.DateDiffDays(SDC.DateTimeActivityCreation, COALESCE(DateTimeActivityClosure, GETUTCDATE()),0,0)) Waiting
WHERE 1=1 -- Logic to have the open activities from a change
	AND DateTimeActivityClosure IS NULL
	AND ActivitySkipped = 0 
	AND ActivityResolved = 0 
	AND ActivityRejected = 0 
	AND ActivityMayStart = 1
)
--SELECT * FROM ChangeActivityCalculation

SELECT
	CC.*
	, CAC.ActivityCount
	, CAC.ActivityApprovedCount
	, CAC.ActivityMayStartCount
	, CAC.ActivitySkippedCount
	, CAC.ActivityRejectedCount
	, CAC.ActivityResolvedCount
	, CAC.ActivityToGoCount
	, CAC.PercentageOfActivitysCompleted

	, CAL.ActivityOperatorGroupSTD
	, CAL.ActivityPlannedStartRank
	, CAL.ActivityLevel
	, CAL.ActivityChangePhaseNumber
	, CAL.ActivityChangePhaseName
	, CAL.ActivityNumber
	, CAL.ActivityBriefDescription
	, CAL.ActivityApproved
	, CAL.ActivityMayStart
	, CAL.ActivityStarted
	, CAL.ActivityResolved
	, CAL.ActivitySkipped
	, CAL.ActivityRejected
	, CAL.DateActivityCreation
	, CAL.DateTimeActivityCreation
	, CAL.DateTimeChangePhaseStart
	, CAL.DateTimeActivityCalculatedStart
	, CAL.DateTimeActivityPreviousClosure
	, CAL.DateActivityStarted
	, CAL.DateTimeActivityStarted
	, CAL.DateTimeActivityClosure
	, CAL.DateTimeActivityLastChanged
	, CAL.DateTimeActivityPlannedStart
	, CAL.DateTimeActivityPlannedEnd

	, CAL.ActivityWaitingWorkDays
	, CAL.ActivityWaitingDays
	, CAL.ActivityAgeWorkDays
	, CAL.ActivityAgeDays
	, CAL.ActivityAgeMinutes
	, CAL.ActivityPlannedDays
	, CAL.ActivityPlannedMinutes
	, CAL.ActivityAgeVsPlannedDiffInDays
	, CAL.ActivityAgeVsPlannedDiffInMinute
	-- If ActivityAgeMinutes exceeds ActivityPlannedMinutes then it's a delay
	, ActivityDelayPlannedBit = CASE
			WHEN ActivityAgeVsPlannedDiffInMinute <= 0 THEN 0
			WHEN ActivityAgeVsPlannedDiffInMinute > 0 THEN 1
			ELSE NULL
		END
FROM
	ChangeCalculation CC
	LEFT JOIN ChangeActivityCount CAC ON CAC.ChangeKey = CC.ChangeKey
	LEFT JOIN ChangeActivityCalculation CAL ON CAL.ChangeKey = CC.ChangeKey
WHERE 1=1
	AND (ActivityStartedRanking = 1 OR ActivityStartedRanking IS NULL) -- Ensure we only get one activity result per change in case of more than one open activity