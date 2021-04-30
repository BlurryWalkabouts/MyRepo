CREATE view [Security].[vwMappingOverview] AS
SELECT ADGroep = [name]
      ,SQLRoleName = [roleName]
	  ,C.CustomerNumber
	  ,Fullname
	  ,G.OperatorGroup
FROM [Security].[AzureGroup] AG
LEFT JOIN [Security].AzureGroupMapping AGM ON (AGM.AzureGroupId = AG.Id)
LEFT JOIN [Dim].[Customer] C ON (C.customerKey = AGM.CustomerKey)
LEFT JOIN [Dim].[OperatorGroup] G ON (G.OperatorGroupKey = AGM.OperatorGroupKey)