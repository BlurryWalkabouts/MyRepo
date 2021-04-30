CREATE VIEW [monitoring].[MissingCustomerKeys]
AS

/* 
The following view runs through several fact and dim tables to check for rows with a negative CustomerKey.
This indicates that for some reason no customer could be found.
*/

WITH cte AS
(
SELECT
	TableName = 'Dim.Object'
--	, id = ObjectKey
	, SourceDatabaseKey
	, CustomerKey
	, CustomerName = NULL
FROM
	[$(OGDW)].Dim.[Object]
WHERE 1=1
	AND CustomerKey = -1
	AND SourceDatabaseKey <> -1

UNION ALL

SELECT
	TableName = 'Fact.Call'
--	, id = CallSummaryID
	, SourceDatabaseKey = NULL
	, CustomerKey
	, CustomerName = NULL
FROM
	[$(OGDW)].Fact.[Call]
WHERE 1=1
	AND CustomerKey = -1

UNION ALL

SELECT
	TableName = 'Fact.Change'
--	, id = Change_Id
	, SourceDatabaseKey
	, CustomerKey
	, CustomerName
FROM
	[$(OGDW)].Fact.Change
WHERE 1=1
	AND CustomerKey = -1
	AND SourceDatabaseKey <> -1

UNION ALL

SELECT
	TableName = 'Fact.ChangeActivity'
--	, id = ChangeActivity_Id
	, SourceDatabaseKey = ca.SourceDatabaseKey
	, CustomerKey = ca.CustomerKey
	, CustomerName = c.CustomerName
FROM
	[$(OGDW)].Fact.ChangeActivity ca
	LEFT OUTER JOIN [$(OGDW)].Fact.Change c ON ca.ActivityChange = c.ChangeNumber AND ca.SourceDatabaseKey = c.SourceDatabaseKey
WHERE 1=1
	AND ca.CustomerKey = -1
	AND ca.SourceDatabaseKey <> -1

UNION ALL

SELECT
	TableName = 'Fact.Incident'
--	, id = Incident_Id
	, SourceDatabaseKey
	, CustomerKey
	, CustomerName
FROM
	[$(OGDW)].Fact.Incident
WHERE 1=1
	AND CustomerKey = -1
	AND SourceDatabaseKey <> -1

UNION ALL

SELECT
	TableName = 'Fact.Problem'
--	, id = Problem_Id
	, SourceDatabaseKey
	, CustomerKey
	, CustomerName = NULL
FROM
	[$(OGDW)].Fact.Problem
WHERE 1=1
	AND CustomerKey = -1
	AND SourceDatabaseKey <> -1
)

SELECT
	TableName = cte.TableName
	, SourceDatabaseKey = cte.SourceDatabaseKey
	, DatabaseLabel = SD.DatabaseLabel
	, MultipleCustomers = CASE SD.MultipleCustomers
			WHEN 0 THEN 'No'
			WHEN 1 THEN 'Yes'
			ELSE 'N/A'
		END
	, CustomerName = cte.CustomerName
	, MissingCustomerKeyCount = COUNT(cte.CustomerKey)
FROM
	cte
	LEFT OUTER JOIN setup.SourceDefinition SD ON cte.SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.DimCustomer C1 ON SD.DatabaseLabel = C1.[Name]
	LEFT OUTER JOIN setup.SourceTranslation ST ON cte.CustomerName = ST.SourceValue AND SD.DatabaseLabel = ST.SourceName
		AND ST.DWColumnName = 'CustomerName' AND TranslatedColumnName = 'CustomerAbbreviation'
	LEFT OUTER JOIN setup.DimCustomer C2 ON ST.TranslatedValue = C2.[Name]
GROUP BY
	cte.TableName
	, cte.SourceDatabaseKey
	, SD.DatabaseLabel
	, SD.MultipleCustomers
	, cte.CustomerName