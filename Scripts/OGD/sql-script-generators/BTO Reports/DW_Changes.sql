USE OGDW

;WITH ContractValues(Team, Customer, DebitNumber, Estimation) AS (
			SELECT 'MKBO' AS Team,		'Nibud' AS Customer,		RIGHT('000000' + CAST('002687' AS VARCHAR(6)), 6) AS DebitNumber,		38. AS CreatedEstimation
	UNION	SELECT 'OGD ICT-Diensten',	'OGD',						RIGHT('000000' + CAST('001013' AS VARCHAR(6)), 6),						666.
	UNION	SELECT 'MKBO',				'Greenwheels',				RIGHT('000000' + CAST('003755' AS VARCHAR(6)), 6),						30.
	UNION	SELECT 'MKBO',				'C.R.O.W.',					RIGHT('000000' + CAST('003348' AS VARCHAR(6)), 6),						96.
	UNION	SELECT 'MKBO',				'KNCV Tuberculosefonds',	RIGHT('000000' + CAST('002271' AS VARCHAR(6)), 6),						115.
	UNION	SELECT 'MKBO',				'Triple Jump',				RIGHT('000000' + CAST('003690' AS VARCHAR(6)), 6),						150.
	UNION	SELECT 'MKBO',				'Aedes',					RIGHT('000000' + CAST('003683' AS VARCHAR(6)), 6),						20.	
	UNION	SELECT 'MKBO',				'Intravacc',				RIGHT('000000' + CAST('003751' AS VARCHAR(6)), 6),						162.
	UNION	SELECT 'MKBO',				'KPC Groep',				RIGHT('000000' + CAST('003392' AS VARCHAR(6)), 6),						 25.
	UNION	SELECT 'MKBO',				'NRG Value',				RIGHT('000000' + CAST('003724' AS VARCHAR(6)), 6),						 70.
	UNION	SELECT 'Sigma',				'Fondsenbeheer',			RIGHT('000000' + CAST('003685' AS VARCHAR(6)), 6),						265.
	UNION	SELECT 'Sigma',				'BPD',						RIGHT('000000' + CAST('003775' AS VARCHAR(6)), 6),						450.
	UNION	SELECT 'Sigma',				'BIM',						RIGHT('000000' + CAST('003833' AS VARCHAR(6)), 6),						205.
	UNION	SELECT 'Omega',				'Accare',					RIGHT('000000' + CAST('003746' AS VARCHAR(6)), 6),						320.
	UNION	SELECT 'Omega',				'GGNet',					RIGHT('000000' + CAST('003696' AS VARCHAR(6)), 6),						100.
	UNION	SELECT 'Alpha',				'Van Hall Larenstein',		RIGHT('000000' + CAST('002548' AS VARCHAR(6)), 6),						0.
	UNION	SELECT 'Alpha',				'Stichting Het Rijnlands Lyceum', RIGHT('000000' + CAST('001649' AS VARCHAR(6)), 6),				160.
	UNION	SELECT 'Network Outsourcing', 'Corbion', RIGHT('000000' + CAST('002529' AS VARCHAR(6)), 6), 0.
	UNION	SELECT 'Alpha', 'Regio College Zaanstreek-Waterland', RIGHT('000000' + CAST('001942' AS VARCHAR(6)), 6), 250.
	UNION	SELECT 'Alpha', 'SintLucas', RIGHT('000000' + CAST('001391' AS VARCHAR(6)), 6), 30.
	UNION	SELECT 'Sigma', 'Bouwinvest', RIGHT('000000' + CAST('000957' AS VARCHAR(6)), 6), 240.
	UNION	SELECT 'Alpha', 'Gemeente Molenwaard', RIGHT('000000' + CAST('002827' AS VARCHAR(6)), 6), 0.
	UNION	SELECT 'Alpha', 'Kennedy Van der Laan', RIGHT('000000' + CAST('003527' AS VARCHAR(6)), 6), 0.
	UNION	SELECT 'Sigma', 'Univé', RIGHT('000000' + CAST('003588' AS VARCHAR(6)), 6), 0.
	UNION	SELECT 'Alpha', 'De Jutters', RIGHT('000000' + CAST('003466' AS VARCHAR(6)), 6), 0.
	UNION	SELECT 'Sigma', 'NIBC', RIGHT('000000' + CAST('001280' AS VARCHAR(6)), 6), 1109.0
	UNION	SELECT 'MKBO', 'OGD (MKBO Intern)', RIGHT('000000' + CAST('' AS VARCHAR(6)), 6), 0.
	UNION	SELECT 'MKBO', 'Nederlands Openluchtmuseum', RIGHT('000000' + CAST('003867' AS VARCHAR(6)), 6), 30. * 52 / 12
)
,FirstCleanUpPass AS (
	SELECT DISTINCT
		 [Team]
		,Customer = Fullname
		,ChangeNumber
		,[ChangeFinances] = CONCAT(CV.DebitNumber,'-',ChangeNumber)
		,Category
		,Subcategory
		,DescriptionBrief
		,OriginalIncident
		,CancelledByOperator
		,ChangeType
		,Type
		,TypeSTD
		,Template
		,Coordinator
		,CurrentPhaseSTD
		,Evaluation
		,Implemented
		,Rejected
		,Started
		,CreationDate
		,AuthorizationDate
		,NoGoDateExtChange
		,CancelDateExtChange
		,EndDateExtChange
		,ChangeDate
		,ImplDateExtChange
		,PlannedAuthDateRequestChange
		,PlannedImplDate
		,PlannedFinalDate
		,RejectionDate
		,RequestDate
		,SubmissionDateRequestChange
		,ClosureDate
		,FinishedDate = CASE 
							WHEN (Fullname IN ('Univé', 'Fondsenbeheer') AND CurrentPhaseSTD IN ('Afgeronde uitgebreide wijziging', 'Geannuleerde uitgebreide wijziging', 'Afgewezen wijzigingsaanvraag', 'Geannuleerde uitgebreide wijziging')) THEN COALESCE(CompletionDate, ChangeDate)
							WHEN (CompletionDate IS NULL AND RejectionDate IS NULL AND CancelDateExtChange IS NULL AND Customer NOT IN ('Univé', 'Fondsenbeheer')) 
								OR (Customer IN ('Univé', 'Fondsenbeheer') AND (DescriptionBrief NOT LIKE 'Oud wijzigingsnummer: W %'
																		   AND CurrentPhaseSTD NOT IN ('Afgeronde uitgebreide wijziging', 'Geannuleerde uitgebreide wijziging', 'Afgewezen wijzigingsaanvraag', 'Geannuleerde uitgebreide wijziging')
																		   AND CompletionDate IS NULL AND RejectionDate IS NULL AND CancelDateExtChange IS NULL
															)
								) THEN '9999-12-31'
							ELSE CompletionDate
						END
		,CompletionDate = CompletionDate
		,CreationDatetime = CAST(CreationDate AS DATETIME) + CAST(CreationTime AS DATETIME)
		,AuthorizationDatetime = CAST(AuthorizationDate AS DATETIME) + CAST(AuthorizationTime AS DATETIME)
		,NoGoDateExtChangetime = CAST(NoGoDateExtChange AS DATETIME) + CAST(NoGoTimeExtChange AS DATETIME)
		,CancelDateExtChangetime = CAST(CancelDateExtChange AS DATETIME) + CAST(CancelTimeExtChange AS DATETIME)
		,EndDateExtChangetime = CAST(EndDateExtChange AS DATETIME) + CAST(EndTimeExtChange AS DATETIME)
		,ChangeDatetime = CAST(ChangeDate AS DATETIME) + CAST(ChangeTime AS DATETIME)
		,ImplDateExtChangetime = CAST(ImplDateExtChange AS DATETIME) + CAST(ImplTimeExtChange AS DATETIME)
		,PlannedAuthDateRequestChangetime = CAST(PlannedAuthDateRequestChange AS DATETIME) + CAST(PlannedAuthTimeRequestChange AS DATETIME)
		,PlannedImplDatetime = CAST(PlannedImplDate AS DATETIME) + CAST(PlannedImplTime AS DATETIME)
		,PlannedFinalDatetime = CAST(PlannedFinalDate AS DATETIME) + CAST(PlannedFinalTime AS DATETIME)
		,RejectionDatetime = CAST(RejectionDate AS DATETIME) + CAST(RejectionTime AS DATETIME)
		,RequestDatetime = CAST(RequestDate AS DATETIME) + CAST(RequestTime AS DATETIME)
		,SubmissionDateRequestChangetime = CAST(SubmissionDateRequestChange AS DATETIME) + CAST(SubmissionTimeRequestChange AS DATETIME)
		,ClosureDatetime = CAST(ClosureDate AS DATETIME) + CAST(ClosureTime AS DATETIME)
		,CompletionDatetime = CAST(CompletionDate AS DATETIME) + CAST(CompletionTime AS DATETIME)
		,ChangeKey = Change_ID
		,Ranking = DENSE_RANK() OVER (Partition by Change_ID ORDER BY ChangeDate DESC)
		,ResponsibilityOGD = CAST(
			CASE
			-- If MKBO, assume OGD is responsible
				WHEN Team IN ('MKBO', 'OGD ICT-Diensten') THEN 1
				WHEN Customer IN ('Univé', 'Bouwinvest') AND Category IN ('Kantoorautomatisering') THEN 1
				WHEN Coordinator IN ('Loo, Michel van de', 'SSD OGD', 'SERVICEDESK', 'Dompeling, Alex', 'WIJZIGINGSCOÖRDINATIE', 'Frank Smulders', 'Lustenhouwer, Sander') THEN 1 
				WHEN Team = 'Alpha' THEN 1
				ELSE 0
			END
			AS BIT)
	FROM [OGDW].[Fact].[Change] CRQ
	INNER JOIN DIM.Customer C ON (C.CustomerKey = CRQ.CustomerKey)
	INNER JOIN ContractValues CV ON (CV.Customer = C.Fullname)
	WHERE DescriptionBrief NOT LIKE 'Oud wijzigingsnummer: W %'
)
,SecondPass AS (
	SELECT
		 C.*
		,AgeRanking_Overall = DENSE_RANK() OVER (ORDER BY CreationDatetime, ChangeNumber)
		,AgeRanking_OverallOGD = DENSE_RANK() OVER (PARTITION BY ResponsibilityOGD ORDER BY CreationDatetime, ChangeNumber)
		,AgeRanking_PerTeam = DENSE_RANK() OVER (Partition by Team ORDER BY CreationDatetime, ChangeNumber)
		,AgeRanking_PerTeamCustomer = DENSE_RANK() OVER (PARTITION BY Team, Customer ORDER BY CreationDatetime, ChangeNumber)
		-- Logic to determine if a Change is OGD or Non-OGD
		-- Filter out DB Anomalies for OGD
		,CF_Ranking = DENSE_RANK() OVER (Partition by changefinances ORDER BY CreationDatetime DESC)
	FROM FirstCleanUpPass C
	WHERE Ranking = 1
)
SELECT 
	 CC = COUNT(ChangeFinances) OVER (Partition by changefinances)
	,S.*
	,Duration_BusinessDays = P.NumberOfDays
	,Duration_ActualDays = DATEDIFF(day, creationdate, getutcdate())
	,Duration_Average = AVG(P.NumberOfDays) OVER ()
	,ChangeStep = CurrentActivity.PlannedStartRank
	,Activity = CurrentActivity.ActivityNumber
	,Activity_Desc = CurrentActivity.BriefDescription
	,Activity_Waited = Waiting_BusinessDays
	,Activity_Duration = Duration_BusinessDays
	,CurrentActivity.*
	,ActivityCount.*
	,PercentageCompleted = ActivityCount.Resolved * 1. / ActivityCount.ActivityCount
FROM SecondPass S
LEFT JOIN (
	SELECT
		 F.*
		,Duration_BusinessDays = CASE WHEN Skipped = 1 THEN NULL
									  WHEN PreviousCompleted IS NOT NULL OR StartedDatetime IS NOT NULL THEN S.NumberOfDays 
									  ELSE NULL END
		,Duration_Days = CASE	WHEN Skipped = 1 THEN NULL
								WHEN PreviousCompleted IS NOT NULL AND StartedDatetime IS NOT NULL AND StartedDatetime < PreviousCompleted THEN
									DATEDIFF(day, starteddatetime, COALESCE(FinishedDate, GETUTCDATE())) 
								WHEN PreviousCompleted IS NOT NULL OR StartedDatetime IS NOT NULL THEN DATEDIFF(day, COALESCE(PreviousCompleted, StartedDatetime), COALESCE(FinishedDate, GETUTCDATE())) 
								ELSE NULL END
		,Waiting_BusinessDays = W.NumberOfDays
		,Waiting_Days = DATEDIFF(day, ChangeCreationDate, COALESCE(FinishedDate, GETUTCDATE()))
	FROM (
		SELECT 
			   OperatorGroupSTD
			  ,ChangeKey
			  ,PlannedStartRank
			  ,Level
			  ,[ActivityNumber]
			  ,MayStart
			  ,Started
			  ,Skipped
			  ,StartedDatetime = CASE 
									WHEN PlannedStartRank = 1 AND StartedDate IS NULL THEN CAST(CreationDate AS DATETIME) + CAST(CreationTime AS datetime)
									ELSE CAST(StartedDate AS DATETIME) + CAST(StartedTime AS datetime)
								 END
			  ,BriefDescription
			  ,FinishedDate = COALESCE(CAST(ResolvedDate as datetime) + CAST(Resolvedtime as datetime), CAST(RejectedDate as datetime) + CAST(RejectedTime as datetime), CAST(SkippedDate as datetime) + CAST(Skippedtime as datetime))
			  ,PreviousCompleted = LAG(COALESCE(CAST(ResolvedDate as datetime) + CAST(Resolvedtime as datetime), CAST(RejectedDate as datetime) + CAST(RejectedTime as datetime), CAST(SkippedDate as datetime) + CAST(Skippedtime as datetime))) OVER (PARTITION BY ChangeKey ORDER BY PlannedStartRank, MayStart DESC, Started DESC, ActivityNumber)
			  ,ChangeCreationDate = MIN(CAST(CreationDate AS DATETIME) + CAST(CreationTime AS DATETIME)) OVER (Partition BY ChangeKey)
			  ,Ranking = RANK() OVER (PARTITION BY ChangeKey ORDER BY PlannedStartRank, MayStart DESC, Started DESC, ActivityNumber)
		FROM [OGDW].[Fact].[ChangeActivity] CA
		inner JOIN DIM.OperatorGroup OG ON (OG.OperatorGroupKey = CA.OperatorGroupKey)
		--INNER JOIN DIM.Customer C ON (C.CustomerKey = CA.CustomerKey)
		--INNER JOIN ContractValues CV ON (CV.Customer = C.Fullname)
		WHERE ChangeKey != -1
	) F
	CROSS APPLY (
		SELECT NumberOfDays = COUNT(DISTINCT DateKey) FROM Dim.Date WHERE Date > COALESCE(CASE WHEN F.PreviousCompleted > F.StartedDatetime THEN F.StartedDatetime ELSE F.PreviousCompleted END, F.StartedDateTime) AND Date <= COALESCE(FinishedDate, GETUTCDATE()) AND Holiday = 0 AND DayOfWeek NOT IN (6,7)
	) S
	CROSS APPLY (
		SELECT NumberOfDays = COUNT(DISTINCT DateKey) FROM Dim.Date WHERE Date > F.ChangeCreationDate AND Date <= COALESCE(PreviousCompleted, FinishedDate, GETUTCDATE()) AND Holiday = 0 AND DayOfWeek NOT IN (6,7)
	) W
	INNER JOIN (
		SELECT
			 ChangeKey
			,ActivityNumber = MIN(ActivityNumber)
			-- Ranking here to ensure we only get 1 result. Might need to fix this at a later date
			,Ranking = DENSE_RANK() OVER (Partition by ChangeKey ORDER BY StartedDate DESC)
		FROM Fact.ChangeActivity 
		WHERE COALESCE(CAST(ResolvedDate as datetime) + CAST(Resolvedtime as datetime), CAST(RejectedDate as datetime) + CAST(RejectedTime as datetime), CAST(SkippedDate as datetime) + CAST(Skippedtime as datetime)) IS NULL AND Skipped = 0 AND Resolved = 0 AND Rejected = 0 AND MayStart = 1
		GROUP BY ChangeKey, StartedDate
	) C ON (C.ActivityNumber = F.ActivityNumber AND F.ChangeKey = C.ChangeKey AND C.Ranking = 1)
) CurrentActivity ON (CurrentActivity.ChangeKey = S.ChangeKey)
LEFT JOIN (
	SELECT
		 ChangeKey
		,ActivityCount = COUNT(*)
		,StartedCount = SUM(CAST(Started AS INT))
		,SkippedCount = SUM(CAST(Skipped AS INT))
		,MayStartCount = SUM(CAST(MayStart AS INT))
		,Rejected = SUM(CAST(Rejected AS INT))
		,Resolved = SUM(CAST(Resolved AS INT))
		,Approved = SUM(CAST(Approved AS INT))
	FROM Fact.ChangeActivity 
	GROUP BY ChangeKey
) ActivityCount ON (ActivityCount.ChangeKey = S.ChangeKey)
CROSS APPLY (
	SELECT NumberOfDays = COUNT(DISTINCT DateKey) FROM Dim.Date WHERE Date > S.CreationDate AND Date <= COALESCE(CompletionDate, GETUTCDATE()) AND Holiday = 0 AND DayOfWeek NOT IN (6,7)
) P
--WHERE CreationDate >= '2016-10-01' AND CreationDate < '2016-11-01'
WHERE CF_Ranking = 1
ORDER BY CC DESC, ChangeFinances, AgeRanking_Overall, Customer, ChangeNumber