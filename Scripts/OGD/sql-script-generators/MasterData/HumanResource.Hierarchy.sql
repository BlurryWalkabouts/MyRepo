CREATE VIEW [HumanResources].[ResourceHierarchy] AS 
	With OrganizationHierarchy AS (
		SELECT 
			 Lvl = 0
			,R.*
		FROM [HumanResources].[AllResources] R
		WHERE R.Manager_Code IS NULL
		UNION ALL
		SELECT 
			 Lvl = M.Lvl + 1
			,R.*
		FROM [HumanResources].[AllResources] R
		INNER JOIN [OrganizationHierarchy] M ON (M.Code = R.Manager_Code)
	)
	SELECT * FROM OrganizationHierarchy

/*
SELECT * FROM [HumanResources].[AllResources] 
where firstName = 'Onno' or LastName = 'Wesenbeek'
WHERE code not in (
SELECT 
	code
FROM OrganizationHierarchy 
--ORDER BY Lvl
-- 25A715D3-7C61-58DC-95E7-52A6F5C55DC0
)
*/
SELECT 
	*
FROM OrganizationHierarchy 
ORDER BY Lvl

--select * from HumanResources.Employee where LastName = 'Wesenbeek'

select * from HumanResources.AllResources where LastName = 'Bemmelen'