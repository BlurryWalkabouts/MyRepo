SET DateFirst 1

--alter view finance.HoursAssignmentPlanned AS
-- Tally table to explode assignment date range into weeklies
;WITH 
	 lv0 AS (SELECT 0 g UNION ALL SELECT 0)
    ,lv1 AS (SELECT 0 g FROM lv0 a CROSS JOIN lv0 b) -- 4
    ,lv2 AS (SELECT 0 g FROM lv1 a CROSS JOIN lv1 b) -- 16
    ,lv3 AS (SELECT 0 g FROM lv2 a CROSS JOIN lv2 b) -- 256
	--,lv4 AS (SELECT 0 g FROM lv3 a CROSS JOIN lv3 b)
    ,Tally (n) AS (SELECT n = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM lv3)
,Assignments AS (
	select
		 [employeeid]
		,[DateAssignmentStart] = CASE WHEN DATEDIFF(month, v.startdatum, (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')) > 3 THEN DATEADD(MONTH, -1, (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')) ELSE v.startdatum END
		,[DateAssignmentEnd] = CASE WHEN DATEDIFF(month, (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time'), v.einddatum) > 2 THEN DATEADD(MONTH, 3, (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')) ELSE v.einddatum END
		,[DatePlanningAdjustedStart] = CASE WHEN pa.startdate > v.einddatum THEN NULL ELSE pa.startdate END
		,AssignmentId = v.unid
		,ProjectId = p.unid
		,RatePerHour = v.[uurprijs]
		,[HoursAssignment] = v.werklast
		,[HoursPlanned] = pa.amount, v.werklast
		,[HoursExpected] = COALESCE(pa.amount, v.werklast)
		,[TurnoverAssigned] = v.[uurprijs] * v.werklast
		,[TurnoverPlanned] = v.uurprijs * pa.amount
		,[TurnoverExpected] = v.uurprijs * COALESCE(pa.amount, v.werklast)
		,[BusinessUnit] = COALESCE(bu.tekst, 'OGD')
		,[Team] = COALESCE(team.tekst, 'Algemeen')
		,[Project] = p.projectnaam
		,[Customer] = k.bedrijf
	from
		dbo.voordracht v
		inner join dbo.project p ON (p.unid = v.projectid)
		INNER JOIN dbo.projectgroep pg ON (pg.unid = p.[projectgroepid])
		INNER JOIN dbo.klant k ON (k.unid = pg.klantid)
		left join dbo.planning_assignment pa ON (pa.assignmentid = v.unid)
		inner join dbo.werknemer w ON (w.unid = v.employeeid)
		left join dbo.vrijopzoek bu ON (bu.unid = w.exveld004)
		left join dbo.vrijopzoek team ON (team.unid = w.extra_team)
	where 
		v.[status] > 0
		AND v.startdatum <= (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')
		AND DATEDIFF(month, (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time'), v.einddatum) < 3
		AND v.einddatum >= '2018-01-01'
		AND (pa.amount > 0 OR v.werklast > 0)
		AND p.[status] > 0
)
,FixAssignmentStartDate AS (
	SELECT
		 [EmployeeId]
		,[AssignmentId]
		,[ProjectId]
		,[DateAssignmentStart] = 
		CASE 
			WHEN LAG(DateAssignmentEnd) OVER (PARTITION BY AssignmentId ORDER BY DateAssignmentStart, DatePlanningAdjustedStart) > DatePlanningAdjustedStart AND DatePlanningAdjustedStart > [DateAssignmentStart] THEN DatePlanningAdjustedStart
			ELSE [DateAssignmentStart]
		END
		,[DateAssignmentEnd] = COALESCE(LEAD(DatePlanningAdjustedStart) OVER (PARTITION BY AssignmentId ORDER BY DateAssignmentStart, DatePlanningAdjustedStart), [DateAssignmentEnd])
		,[DatePlanningAdjustedStart]
		,[RatePerHour]
		,[HoursAssignment]
		,[HoursPlanned]
		,[HoursExpected]
		,[TurnoverAssigned]
		,[TurnoverPlanned]
		,[TurnoverExpected]
		,[BusinessUnit]
		,[Team]
		,[Project]
		,[Customer]
	FROM 
		Assignments
)
SELECT
		 [EmployeeId]
		,[AssignmentId]
		,[ProjectId]
		,[DateAssignmentStart] 
		,[DateAssignmentEnd]
		,[Year] = DATEPART(YEAR, DATEADD(WEEK, n-1, [DateAssignmentStart]))
		,[Week] = DATEPART(WEEK, DATEADD(WEEK, n-1, [DateAssignmentStart]))
		,[Year-Week] = CONCAT(DATEPART(YEAR, DATEADD(WEEK, n-1, [DateAssignmentStart])), '-', DATEPART(WEEK, DATEADD(WEEK, n-1, [DateAssignmentStart])))
		,[RatePerHour]
		,[HoursAssignment]
		,[HoursPlanned]
		,[HoursExpected]
		,[TurnoverAssigned]
		,[TurnoverPlanned]
		,[TurnoverExpected]
		,[BusinessUnit]
		,[Team]
		,[Project]
		,[Customer]
FROM 
	FixAssignmentStartDate 
	CROSS JOIN tally
WHERE
	(tally.n-1) <= DATEDIFF(WEEK, [DateAssignmentStart], [DateAssignmentEnd])