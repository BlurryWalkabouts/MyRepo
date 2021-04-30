use topdesk_dw
GO

/*
SELECT DISTINCT OG.[OperatorGroupKey]
      ,OG.[SourceDatabaseKey]
	  ,FullName
	  ,C.CustomerKey
      ,[OperatorGroupID]
      ,[OperatorGroup]
      ,[OperatorGroupSTD]
FROM [Dim].[OperatorGroup] OG
INNER JOIN Fact.Incident I ON (I.SourceDatabaseKey = OG.SourceDatabaseKey)
INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
where OperatorGroupSTD like 'Technisch Applicatiebeheer' and OperatorGroup NOT IN ('Aoic', 'Remote monitor', 'IA Applicatiebeheer', 'Software Deployment', 'OGD-Virtueel Kantoor', 'Keylane', 'Bi_Ddp_Ab', 'Expertise Extern', 'Bi_Ddp_Tb', 'Specials Dba
Technisch Applicatiebeheer', 'Capgemini Tia-Aov Beheer', 'Ddp Platform Team', 'Topdesk Technisch Beheer', 'Specials Dba')
and SysAdminTeam IN ('MKBO', 'Alpha', 'Omega', 'Sigma', 'Delta')
and I.CreationDate > '2017-01-01'
and OperatorGroup NOT IN ('Infrateam')
order by Fullname
*/

--DELETE FROM Security.AzureGroupMapping WHERE AzureGroupID IN (1,2,3,4,11, 16)

;WITH IndividualStatements AS (
	SELECT DISTINCT
		C.Fullname,
		--QueryText = 'INSERT INTO Security.AzureGroupMapping (azureGroupId, customerKey, operatorGroupKey, operatorGroupGuid)' + char(13) +
		--'VALUES (4, ' + CAST(C.CustomerKey AS NVARCHAR(100)) + ', ' + CAST(OG.OperatorGroupKey AS NVARCHAR(100)) + ', ' + COALESCE('''' + CAST(OperatorGroupID AS nvarchar(100)) + '''', 'NULL') + ')'
		 azureGroupId = 4
		,customerKey = C.CustomerKey
		,OperatorGroupKey = OG.OperatorGroupKey
		,OperatorGroupGuid = OG.OperatorGroupID
	FROM [Dim].[OperatorGroup] OG
	INNER JOIN Fact.Incident I ON (I.SourceDatabaseKey = OG.SourceDatabaseKey)
	INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
	where OperatorGroupSTD like '%systeembeheer%'
	and SysAdminTeam IN ('Delta')
	and I.CreationDate > '2017-01-01'
	and OperatorGroup NOT IN ('Infrateam')
	UNION ALL
	SELECT DISTINCT
		C.Fullname,
		--'INSERT INTO Security.AzureGroupMapping (azureGroupId, customerKey, operatorGroupKey, operatorGroupGuid)' + char(13) +
		--'VALUES (1, ' + CAST(C.CustomerKey AS NVARCHAR(100)) + ', ' + CAST(OG.OperatorGroupKey AS NVARCHAR(100)) + ', ' + COALESCE('''' + CAST(OperatorGroupID AS nvarchar(100)) + '''', 'NULL') + ')'
		 azureGroupId = 1
		,customerKey = C.CustomerKey
		,OperatorGroupKey = OG.OperatorGroupKey
		,OperatorGroupGuid = OG.OperatorGroupID
	FROM [Dim].[OperatorGroup] OG
	INNER JOIN Fact.Incident I ON (I.SourceDatabaseKey = OG.SourceDatabaseKey)
	INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
	where OperatorGroupSTD like '%systeembeheer%'
	and SysAdminTeam IN ('Sigma')
	and I.CreationDate > '2017-01-01'
	and OperatorGroup NOT IN ('Infrateam')
	UNION ALL
	SELECT DISTINCT
		C.Fullname,
		--'INSERT INTO Security.AzureGroupMapping (azureGroupId, customerKey, operatorGroupKey, operatorGroupGuid)' + char(13) +
		--'VALUES (2, ' + CAST(C.CustomerKey AS NVARCHAR(100)) + ', ' + CAST(OG.OperatorGroupKey AS NVARCHAR(100)) + ', ' + COALESCE('''' + CAST(OperatorGroupID AS nvarchar(100)) + '''', 'NULL') + ')'
		 azureGroupId = 2
		,customerKey = C.CustomerKey
		,OperatorGroupKey = OG.OperatorGroupKey
		,OperatorGroupGuid = OG.OperatorGroupID	
	FROM [Dim].[OperatorGroup] OG
	INNER JOIN Fact.Incident I ON (I.SourceDatabaseKey = OG.SourceDatabaseKey)
	INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
	where OperatorGroupSTD like '%systeembeheer%'
	and SysAdminTeam IN ('Omega')
	and I.CreationDate > '2017-01-01'
	and OperatorGroup NOT IN ('Infrateam')
	UNION ALL
	SELECT DISTINCT
		C.Fullname,
		--'INSERT INTO Security.AzureGroupMapping (azureGroupId, customerKey, operatorGroupKey, operatorGroupGuid)' + char(13) +
		--'VALUES (3, ' + CAST(C.CustomerKey AS NVARCHAR(100)) + ', ' + CAST(OG.OperatorGroupKey AS NVARCHAR(100)) + ', ' + COALESCE('''' + CAST(OperatorGroupID AS nvarchar(100)) + '''', 'NULL') + ')'
		 azureGroupId = 3
		,customerKey = C.CustomerKey
		,OperatorGroupKey = OG.OperatorGroupKey
		,OperatorGroupGuid = OG.OperatorGroupID	
	FROM [Dim].[OperatorGroup] OG
	INNER JOIN Fact.Incident I ON (I.SourceDatabaseKey = OG.SourceDatabaseKey)
	INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
	where OperatorGroupSTD like '%systeembeheer%'
	and SysAdminTeam IN ('Alpha')
	and I.CreationDate > '2017-01-01'
	and OperatorGroup NOT IN ('Infrateam')
	UNION ALL
	SELECT DISTINCT
		C.Fullname,
		--'INSERT INTO Security.AzureGroupMapping (azureGroupId, customerKey, operatorGroupKey, operatorGroupGuid)' + char(13) +
		--'VALUES (11, ' + CAST(C.CustomerKey AS NVARCHAR(100)) + ', ' + CAST(OG.OperatorGroupKey AS NVARCHAR(100)) + ', ' + COALESCE('''' + CAST(OperatorGroupID AS nvarchar(100)) + '''', 'NULL') + ')'
		 azureGroupId = 11
		,customerKey = C.CustomerKey
		,OperatorGroupKey = OG.OperatorGroupKey
		,OperatorGroupGuid = OG.OperatorGroupID	
	FROM [Dim].[OperatorGroup] OG
	INNER JOIN Fact.Incident I ON (I.SourceDatabaseKey = OG.SourceDatabaseKey)
	INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
	where OperatorGroupSTD like 'netwerkbeheer'
	and SysAdminTeam IN ('MKBO', 'Alpha', 'Omega', 'Sigma', 'Delta')
	and I.CreationDate > '2017-01-01'
	and OperatorGroup NOT IN ('Infrateam')
	UNION ALL
	SELECT DISTINCT
		C.Fullname,
		--'INSERT INTO Security.AzureGroupMapping (azureGroupId, customerKey, operatorGroupKey, operatorGroupGuid)' + char(13) +
		--'VALUES (16, ' + CAST(C.CustomerKey AS NVARCHAR(100)) + ', ' + CAST(OG.OperatorGroupKey AS NVARCHAR(100)) + ', ' + COALESCE('''' + CAST(OperatorGroupID AS nvarchar(100)) + '''', 'NULL') + ')'
		 azureGroupId = 16
		,customerKey = C.CustomerKey
		,OperatorGroupKey = OG.OperatorGroupKey
		,OperatorGroupGuid = OG.OperatorGroupID
	FROM [Dim].[OperatorGroup] OG
	INNER JOIN Fact.Incident I ON (I.SourceDatabaseKey = OG.SourceDatabaseKey)
	INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
	where OperatorGroupSTD like 'Technisch Applicatiebeheer' and OperatorGroup NOT IN ('Aoic', 'Remote monitor', 'IA Applicatiebeheer', 'Software Deployment', 'OGD-Virtueel Kantoor', 'Keylane', 'Bi_Ddp_Ab', 'Expertise Extern', 'Bi_Ddp_Tb', 'Specials Dba
	Technisch Applicatiebeheer', 'Capgemini Tia-Aov Beheer', 'Ddp Platform Team', 'Topdesk Technisch Beheer', 'Specials Dba')
	and SysAdminTeam IN ('MKBO', 'Alpha', 'Omega', 'Sigma', 'Delta')
	and I.CreationDate > '2017-01-01'
	and OperatorGroup NOT IN ('Infrateam')
)
select azureGroupId, customerKey, OperatorGroupKey, OperatorGroupGuid from IndividualStatements