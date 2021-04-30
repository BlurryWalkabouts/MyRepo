;WITH CustomerEstimation(Customer, Estimation) AS (
			SELECT 'Nibud', 38
	UNION	SELECT 'Greenwheels', 30
	UNION	SELECT 'C.R.O.W.', 96
	UNION	SELECT 'KNCV Tuberculosefonds', 115
	UNION	SELECT 'Triple Jump', 150
	UNION	SELECT 'Aedes', 20
	UNION	SELECT 'Intravacc', 162
	UNION	SELECT 'KPC Groep', 25
	UNION	SELECT 'NRG Value', 70
)
,FirstBatch AS (
	SELECT 
		 C.Fullname
		,Month = DATEPART(month, incidentDate)
		,TicketCount = COUNT(*)
		,P1Count = SUM(CASE WHEN PriorityStd = 'P1' THEN 1 ELSE 0 END)
		,EstimatedInContract = E.Estimation
		,CorrectedCount = COUNT(*) - E.Estimation
		,TicketAverage = AVG(COUNT(*)) OVER (PARTITION BY C.FullName)
		,TicketAverageCorrected = AVG(COUNT(*)) OVER (PARTITION BY C.FullName) - E.Estimation
		,ScaledCount = CAST((COUNT(*) - MIN(COUNT(*)) OVER (PARTITION BY C.FullName)) / (MAX(COUNT(*)) OVER (PARTITION BY C.FullName) * 1.0 - MIN(COUNT(*)) OVER (PARTITION BY C.FullName) * 1.0) AS NUMERIC(10,2))
		,ScaledEstimation = CAST((E.Estimation - MIN(COUNT(*)) OVER (PARTITION BY C.FullName)) / (MAX(COUNT(*)) OVER (PARTITION BY C.FullName) * 1.0 - MIN(COUNT(*)) OVER (PARTITION BY C.FullName) * 1.0) AS NUMERIC(10,2))
		,PercAboveEstimation = CAST(CAST((COUNT(*) - E.Estimation) / (E.Estimation * 1.0 ) AS NUMERIC(10,4)) * 100 AS NUMERIC(10,2))
		,StdDev = CAST(STDEV(COUNT(*)) OVER (PARTITION BY C.FullName) AS NUMERIC(10,2))
		,[Z-Score] = CAST((COUNT(*) - AVG(COUNT(*)) OVER (PARTITION BY C.FullName)) / STDEV(COUNT(*)) OVER (PARTITION BY C.FullName) AS NUMERIC(10,2))
	FROM [OGDW].[Fact].[Incident] I
	INNER JOIN DIM.Customer C ON (C.CustomerKey = I.CustomerKey)
	INNER JOIN CustomerEstimation E ON (E.Customer = C.Fullname)
	WHERE DATEPART(year, IncidentDate) >= 2016 AND DATEPART(month, IncidentDate) != 12
	GROUP BY C.Fullname, DATEPART(month, incidentDate), E.Estimation
)
,Vector AS (
	SELECT DISTINCT
		 F.FullName
		,VectorLengthSquared = SUM(POWER(F.TicketCount, 2)) OVER (PARTITION BY F.FullName)
	FROM FirstBatch F
)
SELECT
	 F.*
	,Norm = CAST(SQRT(V.VectorLengthSquared) AS NUMERIC(10,2))
	,Normalized = CAST(F.TicketCount / SQRT(V.VectorLengthSquared) AS NUMERIC(10,2))
	,NormalizedSquared = CAST(POWER(F.TicketCount / SQRT(V.VectorLengthSquared),2) AS NUMERIC(10,2))
	,DistFunction = (1 / sqrt(2 * pi())) * (exp((-POWER([Z-Score],2) / 2)))
FROM FirstBatch F
INNER JOIN Vector V ON (V.Fullname = F.Fullname)
ORDER BY Fullname, Month