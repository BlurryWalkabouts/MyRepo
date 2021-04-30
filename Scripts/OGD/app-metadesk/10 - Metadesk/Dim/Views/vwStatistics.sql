CREATE VIEW [Dim].[vwStatistics] AS
SELECT 
	 C.CustomerKey
	,C.CustomerNumber
	,C.FullName
	,OPS = OPS.Cnt
	,INC = INC.cnt
	,CRQ = CRQ.cnt
	,CRQAC = CRQAC.cnt
	,PBM = PBM.cnt
	,OA = OA.cnt
FROM
	Dim.Customer C
LEFT JOIN (
	SELECT customerkey, cnt = count(*)
	FROM Dim.OperatorGroup
	group by customerkey
) OPS ON (OPS.customerkey = C.Customerkey)
LEFT JOIN (
	SELECT customerkey, cnt = count(*)
	FROM [Fact].[Incident]
	group by customerkey
) INC ON (INC.CustomerKey = C.CustomerKey)
LEFT JOIN (
	SELECT customerkey, cnt = count(*)
	FROM [Fact].Change
	group by customerkey
) CRQ ON (CRQ.customerkey = C.Customerkey)
LEFT JOIN (
	SELECT customerkey, cnt = count(*)
	FROM [Fact].ChangeActivity
	group by customerkey
) CRQAC ON (CRQAC.customerkey = C.Customerkey)
LEFT JOIN (
	SELECT customerkey, cnt = count(*)
	FROM [Fact].Problem
	group by customerkey
) PBM ON (PBM.customerkey = C.Customerkey)
LEFT JOIN (
	SELECT customerkey, cnt = count(*)
	FROM [Fact].OperationalActivity
	group by customerkey
) OA ON (OA.customerkey = C.Customerkey)