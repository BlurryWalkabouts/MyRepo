DECLARE @Date DATETIME = DATEADD(year, -1, GETUTCDATE())

;WITH ContractValues(Team, Customer, Estimation) AS (
			SELECT 'MKBO', 'Nibud', 38.
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
	UNION	SELECT 'MKBO', 'MKBO', 0.
	UNION	SELECT 'MKBO', 'Nederlands Openluchtmuseum', 130.0
)
,GroupsOGD(GroupName) AS (
			SELECT 'Systeembeheer'
	UNION	SELECT 'Majormeldingenbeheer'
	UNION	SELECT 'Servicedesk'
	UNION	SELECT 'Systeembeheercoördinatie'
	UNION	SELECT 'Topdesk Applicatiebeheer'
	UNION	SELECT 'Configuratiebeheer'
	UNION	SELECT 'Werkplekbeheercoördinatie'
	UNION	SELECT 'Netwerkbeheer'
	UNION	SELECT 'Procescoördinatie'
	UNION	SELECT 'Technisch Applicatiebeheer'
	UNION	SELECT 'Werkplekbeheer'
)	
SELECT
	 D.CalendarYear
	,D.MonthOfYear
	,PowerBIDate = DATEFROMPARTS(D.CalendarYear, D.MonthOfYear, 01)
	,YearMonth = CONCAT(D.CalendarYear, '-', D.MonthOfYear)
	,Backlog.Fullname
	,BackLogCount = Count(*)
	,OperatorGroup = OperatorGroupStd
	,IsOGDGroup
	,Average_Previous3Months = COALESCE(AVG(COUNT(*)) OVER (PARTITION BY FullName ORDER BY CalendarYear, D.MonthOfYear, OperatorGroupSTD ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING), 0)
	,Average_Previous12Months = COALESCE(AVG(COUNT(*)) OVER (PARTITION BY FullName ORDER BY CalendarYear, D.MonthOfYear, OperatorGroupSTD ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING), 0)
	,Average_Year = AVG(COUNT(*)) OVER (PARTITION BY FullName, CalendarYear ORDER BY CalendarYear)
	,Average_Overall = AVG(COUNT(*)) OVER (PARTITION BY FullName)
FROM (
	SELECT DISTINCT 
		 CalendarYear
		,MonthOfYear
	FROM Dim.[Date] D
	--WHERE D.Date >= DATEFROMPARTS(DATEPART(YEAR, @Date), DATEPART(MONTH, @Date), 01) AND D.Date <= GETUTCDATE()
	WHERE D.Date >= '2011-01-01' AND D.Date <= GETUTCDATE()
) D
LEFT JOIN (
	SELECT
		Fullname = CASE WHEN C.Fullname = 'MKBO' THEN 'OGD (MKBO Intern)' ELSE C.Fullname END
		,CreatedMonth = D.MonthOfYear
		,CreatedYear = D.CalendarYear
		,CompletedMonth = G.MonthOfYear
		,CompletedYear = G.CalendarYear
		,IncidentDate
		,CompletionDate
		,OperatorGroupSTD
	    ,IsOGDGroup = CASE WHEN OG.GroupName IS NOT NULL THEN 1 ELSE 0 END
	FROM Fact.Incident I
	INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
	INNER JOIN Dim.Date D ON (D.Date = I.IncidentDate)
	INNER JOIN Dim.OperatorGroup O ON (O.OperatorGroupKey = I.OperatorGroupKey)
	INNER JOIN ContractValues CV ON (CV.Customer = C.Fullname)
	LEFT JOIN GroupsOGD OG ON (OG.GroupName = O.OperatorGroupSTD)
	LEFT JOIN Dim.Date G ON (G.Date = I.CompletionDate)
) Backlog ON
(
	(
		-- First case. Year is equal, but number is lower
		(
			Backlog.CreatedYear = D.CalendarYear AND Backlog.CreatedMonth <= D.MonthOfYear
		)
		-- Second case. Year is lower
		OR
		(
			Backlog.CreatedYear < D.CalendarYear
		)
	)
	AND
	(
		-- First Case:
		(
			Backlog.CompletedYear = D.CalendarYear AND Backlog.CompletedMonth > D.MonthOfYear
		)
		OR
		(
			Backlog.CompletedYear > D.CalendarYear
		)
		OR
		(
			Backlog.CompletionDate IS NULL
		)
	)
)
WHERE Backlog.Fullname IS NOT NULL
GROUP BY CalendarYear, MonthOfYear, Backlog.Fullname, OperatorGroupSTD, IsOGDGroup