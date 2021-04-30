CREATE FUNCTION [Security].[fn_rlsProblemSecurityPredicate](@CustomerKey int, @OperatorGroupKey int, @ToggleOperatorGroup bit)  
    RETURNS TABLE  
    --WITH SCHEMABINDING  
AS  
    RETURN 
		-- Result Set for Azure AD Group Name Mappings
		-- This splits a ";" delimited string of user AD groups into records.
		-- Individual records refer to customer (group) mappings.
		-- This is based upon 
		SELECT 1 as accessResult
		FROM Dim.Customer C
		inner JOIN [Security].[AzureGroupMapping] AGM ON (AGM.CustomerKey = C.CustomerKey)
		inner JOIN [Security].[AzureGroup] G ON (G.id = AGM.azureGroupId and G.IsMember=1)
		WHERE 
		(
			1=1
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
				-- This filters DIM.Customer only
				-- Or other tables without OperatorGroupReferences.
				@CustomerKey = AGM.CustomerKey 
				AND @OperatorGroupKey = -1 
				AND @ToggleOperatorGroup = 0)
			)
		)

		UNION

		-- Result Set for UPN Mappings
		-- This maps gert-jan.terschure@ogd.nl to groups
		SELECT 1 as accessResult
		FROM Dim.Customer C
		inner JOIN [Security].[UserPrincipalNameMapping] AGM ON (AGM.CustomerKey = C.CustomerKey)
		inner JOIN [Security].[UserPrincipalName] G ON (G.id = AGM.userPrincipalNameID)
		inner JOIN (
			SELECT USER_NAME() AS value
		) AG ON (AG.value = G.name)
		WHERE 
		(
			1=1
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
				-- This filters DIM.Customer only
				-- Or other tables without OperatorGroupReferences.
				@CustomerKey = AGM.CustomerKey 
				AND @OperatorGroupKey = -1 
				AND @ToggleOperatorGroup = 0)
			)
		)
		UNION
		-- DB Owner Exceptions
		-- Assume that DBAs will connect without setting session context
		-- This allows DBAs to test RLS by setting context.
		-- For changes we need an exception for CM
		SELECT 1 AS accessResult
		FROM Dim.Customer C
		WHERE ((IS_Member('db_owner') = 1 OR IS_Member('fullAccess') = 1 OR IS_Member('sbsCustomer') = 1)
			  AND SESSION_CONTEXT(N'UserId') IS NULL
			  AND SESSION_CONTEXT(N'Groups') IS NULL)
			  --OR
			  -- CM Exception
			  --(CAST((SELECT SESSION_CONTEXT(N'Groups')) AS NVARCHAR(MAX)) LIKE '%496A2D0F-E345-4C6C-8C2C-7E325B60EB31%')

GO