CREATE FUNCTION [Security].[fn_rlsCustomerSecurityPredicate]
(
	@CustomerKey int
	, @OperatorGroupKey int
	, @ToggleOperatorGroup bit
)  
RETURNS TABLE WITH SCHEMABINDING  
AS
RETURN

-- Result Set for Azure AD Group Name Mappings
-- This splits a ";" delimited string of user AD groups into records.
-- Individual records refer to customer (group) mappings.
-- This is based upon 

SELECT
	AccessResult = 1
FROM
	Dim.Customer C
	INNER JOIN [Security].AzureGroupMapping AGM ON AGM.CustomerKey = C.CustomerKey
	INNER JOIN [Security].AzureGroup G ON G.ID = AGM.AzureGroupID
	INNER JOIN (SELECT [value] FROM STRING_SPLIT(CAST((SELECT SESSION_CONTEXT(N'Groups')) AS nvarchar(max)), ';')) AG 
			-- Latter option allows for GUID mappings instead of AD Group names.
			-- Klantportaal, Metadesk might do that in the future. Best to already
			-- have covered this scenario
		ON (AG.[value] = G.[Name] OR AG.[value] = CAST(G.[Guid] AS nvarchar(50)))
WHERE 1=1
-- Improvements from Azure OGDW which powers klantportaal
-- Will need to be backported
-- AND IsCurrent = 1
-- AND TOPdeskActive = 1
	AND
	(
		(
			@CustomerKey = AGM.CustomerKey
			AND
			(
				@OperatorGroupKey = AGM.OperatorGroupKey
				OR
				(
					-- This allows for "empty group references, so a single suffix/user/group can see all operatorgroups
					-- from a customer without mapping them individually.
					AGM.OperatorGroupKey IS NULL
					AND AGM.OperatorGroupGuid IS NULL
				)
			)
		)
		OR
		(
			-- Hack to only have to write 1 RLS rule.
			-- This filters Dim.Customer only
			-- Or other tables without OperatorGroupReferences.
			@CustomerKey = AGM.CustomerKey
			AND @OperatorGroupKey = -1 
			AND @ToggleOperatorGroup = 0
		)
	)

UNION

-- Result Set for UPN Mappings
-- This maps gert-jan.terschure@ogd.nl to groups

SELECT
	AccessResult = 1
FROM
	Dim.Customer C
	INNER JOIN [Security].UserPrincipalNameMapping AGM ON AGM.CustomerKey = C.CustomerKey
	INNER JOIN [Security].UserPrincipalName G ON G.ID = AGM.UserPrincipalNameID
	INNER JOIN (SELECT [value] = CAST(SESSION_CONTEXT(N'UserId') AS nvarchar(100))) AG ON AG.[value] = G.[Name]
WHERE 1=1
-- Improvements from Azure OGDW which powers klantportaal
-- Will need to be backported
-- AND IsCurrent = 1
-- AND TOPdeskActive = 1
	AND
	(
		(
			@CustomerKey = AGM.CustomerKey
			AND
			(
				@OperatorGroupKey = AGM.OperatorGroupKey
				OR
				(
					-- This allows for "empty group references, so a single suffix/user/group can see all operatorgroups
					-- from a customer without mapping them individually.
					AGM.OperatorGroupKey IS NULL
					AND AGM.OperatorGroupGuid IS NULL
				)
			)
		)
		OR
		(
			-- Hack to only have to write 1 RLS rule.
			-- This filters Dim.Customer only
			-- Or other tables without OperatorGroupReferences.
			@CustomerKey = AGM.CustomerKey
			AND @OperatorGroupKey = -1 
			AND @ToggleOperatorGroup = 0
		)
	)

UNION

-- Result set for UPN Suffix Mappings
-- This splits @UserId from gert-jan.terschure@ogd.nl to ogd.nl
-- mapping table contains a mapping between OGD.NL and groups

SELECT
	AccessResult = 1
FROM
	Dim.Customer C
	INNER JOIN [Security].UserPrincipalNameSuffixMapping AGM ON AGM.CustomerKey = C.CustomerKey
	INNER JOIN [Security].UserPrincipalNameSuffix G ON G.ID = AGM.UserPrincipalNameSuffixID
	INNER JOIN (SELECT [value] = RIGHT(CAST(SESSION_CONTEXT(N'UserId') AS nvarchar(100)), LEN(CAST(SESSION_CONTEXT(N'UserId') AS nvarchar(100))) - CHARINDEX('@', CAST(SESSION_CONTEXT(N'UserId') AS nvarchar(100))))) AG
		ON AG.[value] = G.[Name]
WHERE 1=1
-- Improvements from Azure OGDW which powers klantportaal
-- Will need to be backported
-- AND IsCurrent = 1
-- AND TOPdeskActive = 1
	AND
	(
		(
			@CustomerKey = AGM.CustomerKey
			AND
			(
				@OperatorGroupKey = AGM.OperatorGroupKey 
				OR
				(
					-- This allows for "empty group references, so a single suffix/user/group can see all operatorgroups
					-- from a customer without mapping them individually.
					AGM.OperatorGroupKey IS NULL
					AND AGM.OperatorGroupGuid IS NULL
				)
			)
		)
		OR
		(
			-- Hack to only have to write 1 RLS rule.
			-- This filters Dim.Customer only
			-- Or other tables without OperatorGroupReferences.
			@CustomerKey = AGM.CustomerKey
			AND @OperatorGroupKey = -1 
			AND @ToggleOperatorGroup = 0
		)
	)

UNION

-- DB Owner Exceptions
-- Assume that DBAs will connect without setting session context
-- This allows DBAs to test RLS by setting context.
SELECT AccessResult = 1
FROM Dim.Customer
WHERE 1=1
	AND IS_MEMBER('db_owner') = 1
	AND SESSION_CONTEXT(N'UserId') IS NULL
	AND SESSION_CONTEXT(N'Groups') IS NULL

GO

/*
-- Only use this when you want to enable RLS on the database!
-- If in doubt, call GJ or MV.

CREATE SECURITY POLICY security.customerFilterPolicy
	ADD FILTER PREDICATE security.[fn_rlsCustomerSecurityPredicate](CustomerKey, OperatorGroupKey, 1) ON Fact.Incident,
	ADD FILTER PREDICATE security.[fn_rlsCustomerSecurityPredicate](CustomerKey, -1, 0) ON Dim.Customer,
	ADD FILTER PREDICATE security.[fn_rlsCustomerSecurityPredicate](CustomerKey, OperatorGroupKey, 1) ON Fact.Problem,
	ADD FILTER PREDICATE security.[fn_rlsCustomerSecurityPredicate](CustomerKey, OperatorGroupKey, 1) ON Fact.Change,
	ADD FILTER PREDICATE security.[fn_rlsCustomerSecurityPredicate](CustomerKey, OperatorGroupKey, 1) ON Fact.ChangeActivity
GO
*/