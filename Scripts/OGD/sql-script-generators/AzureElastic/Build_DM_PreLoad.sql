-- Inserted Unified.Customers into Dim.Customer
/*
DELETE FROM Dim.Customer
INSERT INTO Dim.Customer
SELECT * FROM Unified.Customer
--WHERE CustomerNumber != '[Unknown]' and (CustomerActive IS NULL OR CustomerActive = 1) AND CustomerKey < 1500
ORDER BY FullName
*/

/*
SELECT * FROM Dim.Customer WHERE CustomerNumber IN (
	SELECT CustomerNumber FROM Dim.Customer WHERE CustomerNumber != '[unknown]' AND IsCurrent = 1 GROUP BY CustomerNumber HAVING COUNT(*) > 1
)

DELETE FROM Dim.Customer 
WHERE CustomerKey IN (
	SELECT C.CustomerKey
	FROM Dim.Customer C
	left join [TOPDESKDW].[Incident] I ON (C.customerkey = I.customerkey)
	WHERE C.CustomerNumber in ('003098','003533','001449','002884','001380','001380','002062','002062','001449')
	group by C.customerkey HAVING MAX(CreationDate) IS NULL
)
*/

-- Updating DIM and FACT table from LIFTDW to use new CustomerKey from UnifiedView
/*
DELETE FROM Dim.Contactperson
INSERT INTO Dim.ContactPerson
SELECT * FROM Unified.ContactPerson --WHERE CustomerKey IN (185, 345)
*/
/*
DELETE FROM Dim.Project
INSERT INTO Dim.Project
SELECT * FROM Unified.Project 
--WHERE ProjectKey = 40000290
ORDER BY ProjectKey
*/

/*
SELECT * FROM DIM.Customer WHERE CustomerNumber IN (
	SELECT CustomerNumber FROM Dim.Customer GROUP BY CustomerNumber HAVING COUNT(*) > 1 and customernumber <> '[Unknown]'
)
ORDER BY CustomerNumber
--ALTER VIEW Unified.Project AS
SELECT 
	 CP.ProjectKey
	,CP.unid
	,CP.ProjectNumber
	,CP.ProjectName
	,DC.CustomerKey
	,CP.ProductGroup
	,CP.Product
	,CP.ProjectGroupNumber
	,CP.ProjectGroupName
	,CP.ProjectStatus
	,CP.ProjectStartDate
	,CP.ProjectEndDate
	,CP.ProjectCreationDate
	,CP.ProjectChangeDate
	,CP.ProjectArchiveDate
	,CP.Office
FROM LIFTDW.Project CP
LEFT JOIN LIFTDW.Customer C ON (CP.CustomerKey = C.CustomerKey AND C.CustomerKey != -1)
INNER JOIN DIM.Customer DC ON (DC.CustomerNumber = C.CustomerDebitNumber AND DC.CustomerKey != -1)
*/