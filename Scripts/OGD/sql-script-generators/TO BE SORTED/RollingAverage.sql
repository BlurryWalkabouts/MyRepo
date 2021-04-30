-- Contract Estimation of amount of created tickets a month
;WITH ContractValues(Customer, Estimation) AS (
--			SELECT 'Nibud', 38.
--	UNION	SELECT 'Greenwheels', 30.
--	UNION	SELECT 'C.R.O.W.', 96.
--	UNION	SELECT 'KNCV Tuberculosefonds', 115.
--	UNION	SELECT 'Triple Jump', 150.
--	UNION	SELECT 'Aedes', 20.
--	UNION	SELECT 'Intravacc', 162.
--	UNION	SELECT 'KPC Groep', 25.
--	UNION	SELECT 'NRG Value', 70.
--  UNION	SELECT 'Rabo Vastgoedgroup', 205.
--	UNION	SELECT 'Fondsenbeheer', 265.
--	UNION	SELECT 'BPD', 450.
--	UNION	
SELECT 'Accare', 320.
--	UNION	SELECT 'GGNet', 100.
)
-- Overall values
,Overall AS (
	SELECT
		 Customer = C.FullName
		,D.CalendarYear
		,D.MonthOfYear
		,TicketsCreated = COUNT(*)
		,RowNumber = ROW_NUMBER() OVER (PARTITION BY C.FullName ORDER BY D.CalendarYear, D.MonthOfYear)
		,Average_Previous3Months = AVG(COUNT(*)) OVER (PARTITION BY C.FullName ORDER BY CalendarYear, D.MonthOfYear ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING)
		,Average_Previous12Months = AVG(COUNT(*)) OVER (PARTITION BY C.FullName ORDER BY CalendarYear, D.MonthOfYear ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING)
		,Average_Year = AVG(COUNT(*)) OVER (PARTITION BY C.FullName, CalendarYear ORDER BY CalendarYear)
		,Average_Overall = AVG(COUNT(*)) OVER (PARTITION BY C.FullName)
		-- Priority 1
		,P1_TicketsCreated = SUM(CASE WHEN PrioritySTD = 'P1' THEN 1 ELSE 0 END)
		,P1_Average_Previous3Months = AVG(SUM(CASE WHEN PrioritySTD = 'P1' THEN 1 ELSE 0 END)) OVER (PARTITION BY C.FullName ORDER BY CalendarYear, D.MonthOfYear ROWS BETWEEN 4 PRECEDING AND 1 PRECEDING)
		,P1_Average_Previous12Months = AVG(SUM(CASE WHEN PrioritySTD = 'P1' THEN 1 ELSE 0 END)) OVER (PARTITION BY C.FullName ORDER BY CalendarYear, D.MonthOfYear ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING)
		,P1_Average_Year = AVG(SUM(CASE WHEN PrioritySTD = 'P1' THEN 1 ELSE 0 END)) OVER (PARTITION BY C.FullName, CalendarYear ORDER BY CalendarYear)
		,P1_Average_Overall = AVG(SUM(CASE WHEN PrioritySTD = 'P1' THEN 1 ELSE 0 END)) OVER (PARTITION BY C.FullName)
	FROM Fact.Incident I
	INNER JOIN DIM.Customer C ON (C.CustomerKey = I.CustomerKey)
	INNER JOIN DIM.Date D ON (D.Date = I.IncidentDate)
	--WHERE C.FullName = 'Regio College Zaanstreek-Waterland'
	GROUP BY C.Fullname, D.CalendarYear, D.MonthOfYear
)
SELECT 
	 O.Customer
	,CalendarYear
	,MonthOfYear
	,Estimated = CV.Estimation
	,TicketsCreated
	,PercentageOfEstimation = CAST((TicketsCreated - CV.Estimation) / CV.Estimation * 100 AS NUMERIC(10,2))
	,Average_Previous3Months
	,Average_Previous12Months
	,Average_Year
	,Average_Overall
	,P1_TicketsCreated
	,P1_Average_Previous3Months
	,P1_Average_Previous12Months
	,P1_Average_Year
	,P1_Average_Overall
FROM Overall O
INNER JOIN ContractValues CV ON (CV.Customer = O.Customer)