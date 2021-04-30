-- Setting first day of week to monday
--SET DateFirst 1

ALTER VIEW Finance.HoursWrittenPerWeek AS
SELECT 
	 [year-week] = CONCAT(datepart(year, ah.[datum]), '-', datepart(week, ah.[datum]))
	,[uur] = SUM(CAST(ah.seconds / 3600.0 AS NUMERIC(10,2)))
	,[turnover] = SUM(CAST(((ah.seconds / 3600.0) * (ut.procent/100.0) * v.uurprijs * ut.declarabel) AS NUMERIC(10,2)))
	,IsBillable = ut.declarabel
	,IsAssignedToInvoice = CASE WHEN ah.[seen_by_invoice_id] IS NULL THEN 0 ELSE 1 END
	,IsInvoiced = ah.[verwerkt_factuur]
	,[BusinessUnit] = COALESCE(bu.tekst, 'OGD')
	,[Team] = COALESCE(team.tekst, 'Algemeen')	
	,AssignmentId = v.unid
FROM [dbo].[assignment_hour] ah
INNER JOIN dbo.voordracht v ON (v.unid = ah.assignmentid)
INNER JOIN dbo.project p ON (p.unid = v.projectid)
INNER JOIN dbo.projectgroep pg ON (pg.unid = p.[projectgroepid])
INNER JOIN dbo.klant k ON (k.unid = pg.klantid)
INNER JOIN dbo.uurtype ut ON (ut.unid = ah.hourtypeid)
INNER JOIN dbo.werknemer w ON (w.unid = v.employeeid)
left join dbo.vrijopzoek bu ON (bu.unid = w.exveld004)
left join dbo.vrijopzoek team ON (team.unid = w.extra_team)
where ah.datum > '2018-01-01' and ah.datum <= (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time')
GROUP BY 
	 CONCAT(datepart(year, ah.[datum]), '-', datepart(week, ah.[datum]))
	,COALESCE(bu.tekst, 'OGD')
	,COALESCE(team.tekst, 'Algemeen')
	,v.unid
	,ut.declarabel
	,CASE WHEN ah.[seen_by_invoice_id] IS NULL THEN 0 ELSE 1 END
	,ah.[verwerkt_factuur]
--order by [year] desc, [week] desc