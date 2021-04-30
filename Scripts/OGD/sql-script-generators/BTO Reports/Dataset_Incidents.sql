SELECT
	[Team] = CASE
						WHEN C.FullName IN ('Triple Jump','Aedes','Nibud','KPC Groep','Greenwheels','KNCV Tuberculosefonds','Intravacc','NRG Value','C.R.O.W.') THEN 'MKBO' 
						WHEN C.FullName IN ('Kennedy Van der Laan','De Jutters','SintLucas','Gemeente Molenwaard','Regio College Zaanstreek-Waterland','Stichting Het Rijnlands Lyceum','Van Hall Larenstein') THEN 'Alpha'
						WHEN C.Fullname IN ('Accare', 'GGNet') THEN 'Omega'
						WHEN C.Fullname IN ('Univé','Bouwinvest','Fondsenbeheer','BPD','BIM') THEN 'Sigma'
						ELSE 'Other'
					  END
	,Customer = C.FullName
	--,D.CalendarYear
	--,D.CalendarSemester
	--,D.CalendarQuarter
	--,D.MonthOfYear
	--,--D.WeekOfYear
	--,D.[DayOfWeek]
	,D.[Date]
	,IncidentsCreatedPerDay = COUNT(*)
	,IncidentsCreatedMonth = SUM(COUNT(*)) OVER (PARTITION BY C.FullName, CalendarYear, MonthOfYear ORDER BY MonthOfYear)
	,IncidentsCreatedQuarter = SUM(COUNT(*)) OVER (PARTITION BY C.FullName, CalendarYear, CalendarQuarter ORDER BY CalendarQuarter)
	,IncidentsCreatedSemester = SUM(COUNT(*)) OVER (PARTITION BY C.FullName, CalendarYear, CalendarSemester ORDER BY CalendarSemester)
	,IncidentsCreatedWeek = SUM(COUNT(*)) OVER (PARTITION BY C.FullName, CalendarYear, WeekOfYear ORDER BY WeekOfYear)
--CASE WHEN ROW_NUMBER() OVER (ORDER BY [Date]) > 11
--        THEN SUM(Value) OVER (ORDER BY [Date] ROWS BETWEEN 11 PRECEDING AND CURRENT ROW)
--        END

FROM Fact.Incident I
INNER JOIN DIM.Customer C ON (C.CustomerKey = I.CustomerKey)
INNER JOIN DIM.[Date] D ON (D.[Date] = I.IncidentDate)
--WHERE FullName = 'Kennedy van der Laan'
WHERE FullName IN ('C.R.O.W.','BIM','NRG Value','Van Hall Larenstein','Triple Jump','BPD','Stichting Het Rijnlands Lyceum','Aedes','Corbion','Fondsenbeheer','Regio College Zaanstreek-Waterland','Nibud','SintLucas','Bouwinvest','Intravacc','KNCV Tuberculosefonds','Gemeente Molenwaard','Kennedy Van der Laan','Accare','Greenwheels','KPC Groep','Univé','De Jutters','GGNet')
GROUP BY C.Fullname, D.CalendarYear, D.CalendarSemester, D.CalendarQuarter, D.MonthOfYear, D.WeekOfYear, D.[DayOfWeek], D.[Date]
--ORDER BY MonthNumber
ORDER BY Team, Customer, CalendarYear, CalendarSemester, CalendarQuarter, MonthOfYear, D.WeekOfYear, D.[DayOfWeek]