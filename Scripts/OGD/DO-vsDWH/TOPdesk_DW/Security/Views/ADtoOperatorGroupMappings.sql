CREATE VIEW [Security].[ADtoOperatorGroupMappings]
AS

SELECT DISTINCT
	C.Fullname
	, AzureGroupID = 4
	, CustomerKey = C.CustomerKey
	, OperatorGroupKey = OG.OperatorGroupKey
	, OperatorGroupGuid = OG.OperatorGroupID
FROM
	Dim.OperatorGroup OG
	INNER JOIN Fact.Incident I ON I.SourceDatabaseKey = OG.SourceDatabaseKey
	INNER JOIN Dim.Customer C ON C.CustomerKey = I.CustomerKey
WHERE 1=1
	AND OperatorGroupSTD LIKE '%systeembeheer%'
	AND SysAdminTeam IN ('Delta')
	AND I.CreationDate > '2017-01-01'
	AND OperatorGroup NOT IN ('Infrateam')

UNION ALL

SELECT DISTINCT
	C.Fullname
	, AzureGroupID = 2
	, CustomerKey = C.CustomerKey
	, OperatorGroupKey = OG.OperatorGroupKey
	, OperatorGroupGuid = OG.OperatorGroupID
FROM
	Dim.OperatorGroup OG
	INNER JOIN Fact.Incident I ON I.SourceDatabaseKey = OG.SourceDatabaseKey
	INNER JOIN Dim.Customer C ON C.CustomerKey = I.CustomerKey
WHERE 1=1
	AND OperatorGroupSTD LIKE '%systeembeheer%'
	AND SysAdminTeam IN ('Sigma')
	AND I.CreationDate > '2017-01-01'
	AND OperatorGroup NOT IN ('Infrateam')

UNION ALL

SELECT DISTINCT
	C.Fullname
	, AzureGroupID = 3
	, CustomerKey = C.CustomerKey
	, OperatorGroupKey = OG.OperatorGroupKey
	, OperatorGroupGuid = OG.OperatorGroupID	
FROM
	Dim.OperatorGroup OG
	INNER JOIN Fact.Incident I ON I.SourceDatabaseKey = OG.SourceDatabaseKey
	INNER JOIN Dim.Customer C ON C.CustomerKey = I.CustomerKey
WHERE 1=1
	AND OperatorGroupSTD LIKE '%systeembeheer%'
	AND SysAdminTeam IN ('Omega')
	AND I.CreationDate > '2017-01-01'
	AND OperatorGroup NOT IN ('Infrateam')

UNION ALL

SELECT DISTINCT
	C.Fullname
	, AzureGroupID = 1
	, CustomerKey = C.CustomerKey
	, OperatorGroupKey = OG.OperatorGroupKey
	, OperatorGroupGuid = OG.OperatorGroupID	
FROM
	Dim.OperatorGroup OG
	INNER JOIN Fact.Incident I ON I.SourceDatabaseKey = OG.SourceDatabaseKey
	INNER JOIN Dim.Customer C ON C.CustomerKey = I.CustomerKey
WHERE 1=1
	AND OperatorGroupSTD LIKE '%systeembeheer%'
	AND SysAdminTeam IN ('Alpha')
	AND I.CreationDate > '2017-01-01'
	AND OperatorGroup NOT IN ('Infrateam')

UNION ALL

SELECT DISTINCT
	C.Fullname
	, AzureGroupID = 7
	, CustomerKey = C.CustomerKey
	, OperatorGroupKey = OG.OperatorGroupKey
	, OperatorGroupGuid = OG.OperatorGroupID	
FROM
	Dim.OperatorGroup OG
	INNER JOIN Fact.Incident I ON I.SourceDatabaseKey = OG.SourceDatabaseKey
	INNER JOIN Dim.Customer C ON C.CustomerKey = I.CustomerKey
WHERE 1=1
	AND OperatorGroupSTD LIKE 'Netwerkbeheer'
	AND SysAdminTeam IN ('MKBO', 'Alpha', 'Omega', 'Sigma', 'Delta')
	AND I.CreationDate > '2017-01-01'
	AND OperatorGroup NOT IN ('Infrateam')

UNION ALL

SELECT DISTINCT
	C.Fullname
	, AzureGroupID = 8
	, CustomerKey = C.CustomerKey
	, OperatorGroupKey = OG.OperatorGroupKey
	, OperatorGroupGuid = OG.OperatorGroupID
FROM
	Dim.OperatorGroup OG
	INNER JOIN Fact.Incident I ON I.SourceDatabaseKey = OG.SourceDatabaseKey
	INNER JOIN Dim.Customer C ON C.CustomerKey = I.CustomerKey
WHERE 1=1
	AND OperatorGroupSTD LIKE 'Technisch Applicatiebeheer'
	AND OperatorGroup NOT IN ('Aoic', 'Remote monitor', 'IA Applicatiebeheer', 'Software Deployment', 'OGD-Virtueel Kantoor', 'Keylane', 'Bi_Ddp_Ab', 'Expertise Extern', 'Bi_Ddp_Tb',
		'Specials Dba Technisch Applicatiebeheer', 'Capgemini Tia-Aov Beheer', 'Ddp Platform Team', 'Topdesk Technisch Beheer', 'Specials Dba')
	AND SysAdminTeam IN ('MKBO', 'Alpha', 'Omega', 'Sigma', 'Delta')
	AND I.CreationDate > '2017-01-01'
	AND OperatorGroup NOT IN ('Infrateam')