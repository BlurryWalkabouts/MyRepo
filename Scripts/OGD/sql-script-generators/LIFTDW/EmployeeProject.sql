
SELECT DISTINCT
		 [EmployeeNumber]
		,CustomerFullname
		,P.ProjectGroupName
FROM [LIFTDW].[Dim].[Employee] E
LEFT JOIN LIFTDW.Fact.Planning H ON (H.EmployeeKey = E.EmployeeKey)
LEFT JOIN LIFTDW.DIM.Project P ON (P.ProjectKey = h.ProjectKey)
LEFT JOIN [LIFTDW].[Dim].Customer C ON (c.CustomerKey = p.CustomerKey)
where 
	1 = 1
	AND CustomerActive = 1 
	and ProjectStatus > 0 
	and ProjectArchiveDate IS NULL 
	and ProjectEndDate >= GETUTCDATE() 
	and EmployeeNumber NOT IN ('', '[unknown]')
ORDER BY ProjectGroupName, EmployeeNumber