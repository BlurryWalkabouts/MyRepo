CREATE VIEW [log].[AnchorRecordCount]
AS

WITH Incidents AS
(
SELECT
	Anchor = 'Incident'
	, SourceDatabaseKey = IN_SDK_Incident_SourceDatabaseKey
	, AuditDWKey = Metadata_IN_SDK
	, [Count] = COUNT(*)
FROM
	[$(OGDW_AM)].dbo.IN_SDK_Incident_SourceDatabaseKey 
GROUP BY
	IN_SDK_Incident_SourceDatabaseKey
	, Metadata_IN_SDK
)

, [Changes] AS
(
SELECT 
	Anchor = 'Change'
	, SourceDatabaseKey = CH_SDK_Change_SourceDatabaseKey
	, AuditDWKey = Metadata_CH_SDK
	, [Count] = COUNT(*)
FROM
	[$(OGDW_AM)].dbo.CH_SDK_Change_SourceDatabaseKey 
GROUP BY
	CH_SDK_Change_SourceDatabaseKey
	, Metadata_CH_SDK
)

, Callers AS
(
SELECT 
	Anchor = 'Caller'
	, SourceDatabaseKey = CA_SDK_Caller_SourceDatabaseKey
	, AuditDWKey = Metadata_CA_SDK
	, [Count] = COUNT(*)
FROM
	[$(OGDW_AM)].dbo.CA_SDK_Caller_SourceDatabaseKey 
GROUP BY
	CA_SDK_Caller_SourceDatabaseKey
	, Metadata_CA_SDK
)

, OperatorGroups AS
(
SELECT 
	Anchor = 'OperatorGroup'
	, SourceDatabaseKey = OG_SDK_OperatorGroup_SourceDatabaseKey
	, AuditDWKey = Metadata_OG_SDK
	, [Count] = COUNT(*)
FROM
	[$(OGDW_AM)].dbo.OG_SDK_OperatorGroup_SourceDatabaseKey 
GROUP BY
	OG_SDK_OperatorGroup_SourceDatabaseKey
	, Metadata_OG_SDK
)

, Operators AS
(
SELECT 
	Anchor = 'Operator'
	, SourceDatabaseKey = OP_SDK_Operator_SourceDatabaseKey
	, AuditDWKey = Metadata_OP_SDK
	, [Count] = COUNT(*)
FROM
	[$(OGDW_AM)].dbo.OP_SDK_Operator_SourceDatabaseKey 
GROUP BY
	OP_SDK_Operator_SourceDatabaseKey
	, Metadata_OP_SDK
)

SELECT
	a.AuditDWKey
	, a.SourceDatabaseKey
	, a.SourceName
	, a.SourceType
	, IN_count = ISNULL(I.[Count],0)
	, CH_count = ISNULL(CH.[Count],0)
	, CA_count = ISNULL(CA.[Count],0)
	, OG_count = ISNULL(OG.[Count],0)
	, OP_count = ISNULL(OP.[Count],0)
	, a.DWDateCreated
	, a.AMDateImported
	, a.deleted
FROM
	[log].[Audit] a
	LEFT OUTER JOIN Incidents I ON A.AuditDWKey = I.AuditDWKey
	LEFT OUTER JOIN [Changes] CH ON A.AuditDWKey = CH.AuditDWKey
	LEFT OUTER JOIN Callers CA ON A.AuditDWKey = CA.AuditDWKey
	LEFT OUTER JOIN OperatorGroups OG ON A.AuditDWKey = OG.AuditDWKey
	LEFT OUTER JOIN Operators OP ON A.AuditDWKey = OP.AuditDWKey