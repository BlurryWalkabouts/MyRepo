alter view finance.HoursActiveContractPerWeek AS
-- Tally table to explode assignment date range into weeklies
WITH 
	 lv0 AS (SELECT 0 g UNION ALL SELECT 0)
    ,lv1 AS (SELECT 0 g FROM lv0 a CROSS JOIN lv0 b) -- 4
    ,lv2 AS (SELECT 0 g FROM lv1 a CROSS JOIN lv1 b) -- 16
    ,lv3 AS (SELECT 0 g FROM lv2 a CROSS JOIN lv2 b) -- 256
	--,lv4 AS (SELECT 0 g FROM lv3 a CROSS JOIN lv3 b)
    ,Tally (n) AS (SELECT n = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM lv3)
	,ContractHoursPerWeek AS (
		select 
			 [Hour] = 40*(Procent/100)
			,[Type] = cs.tekst
			,[HourRateAdvised] = wc.uurtarief
			,[TurnoverAdvisedMax] = 40*(Procent/100) * wc.uurtarief
			,[IsFlexWorker] = CASE WHEN [onbepaald] = 0 then 1 else 0 end
			,[BusinessUnit] = COALESCE(bu.tekst, 'OGD')
			,[Team] = COALESCE(team.tekst, 'Algemeen')
			,[employeeid] = werknemerid
			,[startdatum] = CASE WHEN DATEDIFF(month, startdatum, (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')) > 3 THEN DATEADD(MONTH, -1, (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')) ELSE startdatum END 
			,[einddatum]
		from
			dbo.wcontract wc
			left join dbo.contractsoort cs ON (cs.unid = wc.contractsoortid)
			inner join dbo.werknemer w ON (w.unid = wc.werknemerid)
			left join dbo.vrijopzoek bu ON (bu.unid = w.exveld004)
			left join dbo.vrijopzoek team ON (team.unid = w.extra_team)
		where 
			wc.[status] > 0
			AND [retour] = 1
			AND [startdatum] <= (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')
			AND ([einddatum] >= (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time') OR einddatum IS NULL)
	)
SELECT 
	 [Year] = DATEPART(YEAR, DATEADD(WEEK, n-1, [startdatum]))
	,[Week] = DATEPART(WEEK, DATEADD(WEEK, n-1, [startdatum]))
	,[Year-Week] = CONCAT(DATEPART(YEAR, DATEADD(WEEK, n-1, [startdatum])), '-', DATEPART(WEEK, DATEADD(WEEK, n-1, [startdatum])))
	,CW.*
FROM ContractHoursPerWeek CW
	CROSS JOIN tally
WHERE
	(tally.n-1) <= DATEDIFF(WEEK, [startdatum], DATEADD(month, 3, startdatum))