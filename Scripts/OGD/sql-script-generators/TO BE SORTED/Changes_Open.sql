USE OGDW

;WITH ContractValues(Team, Customer, Estimation) AS (
			SELECT 'MKBO', 'Nibud', 38.
	UNION	SELECT 'OGD ICT-Diensten', 'OGD', 666.
	UNION	SELECT 'MKBO', 'Greenwheels', 30.
	UNION	SELECT 'MKBO', 'C.R.O.W.', 96.
	UNION	SELECT 'MKBO', 'KNCV Tuberculosefonds', 115.
	UNION	SELECT 'MKBO', 'Triple Jump', 150.
	UNION	SELECT 'MKBO', 'Aedes', 20.
	UNION	SELECT 'MKBO', 'Intravacc', 162.
	UNION	SELECT 'MKBO', 'KPC Groep', 25.
	UNION	SELECT 'MKBO', 'NRG Value', 70.
	UNION	SELECT 'Sigma', 'Fondsenbeheer', 265.
	UNION	SELECT 'Sigma', 'BPD', 450.
	UNION	SELECT 'Sigma', 'BIM', 205.
	UNION	SELECT 'Omega', 'Accare', 320.
	UNION	SELECT 'Omega', 'GGNet', 100.
	UNION	SELECT 'Alpha', 'Van Hall Larenstein', 0.
	UNION	SELECT 'Alpha', 'Stichting Het Rijnlands Lyceum', 160.
	UNION	SELECT 'Network Outsourcing', 'Corbion', 0.
	UNION	SELECT 'Alpha', 'Regio College Zaanstreek-Waterland', 250.
	UNION	SELECT 'Alpha', 'SintLucas', 30.
	UNION	SELECT 'Sigma', 'Bouwinvest', 240.
	UNION	SELECT 'Alpha', 'Gemeente Molenwaard', 0.
	UNION	SELECT 'Alpha', 'Kennedy Van der Laan', 0.
	UNION	SELECT 'Sigma', 'Univé', 0.
	UNION	SELECT 'Alpha', 'De Jutters', 0.
	UNION	SELECT 'Sigma', 'NIBC', 1109.0
	UNION	SELECT 'MKBO', 'OGD (MKBO Intern)', 0.
	UNION	SELECT 'MKBO', 'Nederlands Openluchtmuseum', 30. * 52 / 12
)
,FirstCleanUpPass AS (
	SELECT DISTINCT
		 [Team]
		,Customer = Fullname
		,ChangeNumber
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
		,CompletionDate
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
	WHERE 
		-- Just grabbing Open Changes
		(CompletionDate IS NOT NULL OR RejectionDate IS NOT NULL OR CancelDateExtChange IS NOT NULL) --AND Customer NOT IN ('Univé', 'Fondsenbeheer'))
		-- Univé Filter
		OR (
			Customer IN ('Univé', 'Fondsenbeheer')
			AND (
				DescriptionBrief NOT LIKE 'Oud wijzigingsnummer: W %' 
				AND (
					CurrentPhaseSTD IN ('Afgeronde uitgebreide wijziging', 'Geannuleerde uitgebreide wijziging', 'Afgewezen wijzigingsaanvraag', 'Geannuleerde uitgebreide wijziging') 
					OR
					(CompletionDate IS NOT NULL OR RejectionDate IS NOT NULL OR CancelDateExtChange IS NOT NULL)
				)
			)
		)
)
,SecondPass AS (
	SELECT
		 C.*
		,AgeRanking_Overall = DENSE_RANK() OVER (ORDER BY CreationDatetime, ChangeNumber)
		,AgeRanking_OverallOGD = DENSE_RANK() OVER (PARTITION BY ResponsibilityOGD ORDER BY CreationDatetime, ChangeNumber)
		,AgeRanking_PerTeam = DENSE_RANK() OVER (Partition by Team ORDER BY CreationDatetime, ChangeNumber)
		,AgeRanking_PerTeamCustomer = DENSE_RANK() OVER (PARTITION BY Team, Customer ORDER BY CreationDatetime, ChangeNumber)
		-- Logic to determine if a Change is OGD or Non-OGD
	FROM FirstCleanUpPass C
	WHERE Ranking = 1
)
SELECT 
	 S.*
	,Duration_BusinessDays = P.NumberOfDays
	,Duration_ActualDays = DATEDIFF(day, creationdate, getutcdate())
	,Duration_Average = AVG(P.NumberOfDays) OVER ()
	,ActivityCount.*
	,PercentageCompleted = ActivityCount.Resolved * 1. / ActivityCount.ActivityCount
FROM SecondPass S
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
	SELECT NumberOfDays = COUNT(DISTINCT DateKey) FROM Dim.Date WHERE Date > S.CreationDate AND Date <= GETUTCDATE() AND Holiday = 0 AND DayOfWeek NOT IN (6,7)
) P
WHERE CreationDate >= '2016-10-01' AND CreationDate < '2016-11-01'
ORDER BY AgeRanking_Overall, Customer, ChangeNumber