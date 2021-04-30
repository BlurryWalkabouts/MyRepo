CREATE VIEW [monitoring].[MissingIncidents]
AS

/* View die kijkt of er in het AM openstaande incidenten zijn die in de laaste File Import niet geimporteerd zijn
Gemaakt door Wouter Gielen 20151126 versie 1  */

WITH OpenstaandInAM AS
(
SELECT 
	[Missing Incidents] = [IN_NUM_Incident_IncidentNumber]
--	, [IN_NUM_IN_ID]
--	, [Metadata_IN_NUM]
	, SourceDatabaseKey
--	, SourceName
--	, C.IN_CLD_Incident_ClosureDate
--	, IN_CHD_Incident_ChangeDate
FROM
	[$(OGDW_AM)].[dbo].[IN_NUM_Incident_IncidentNumber] I
	LEFT JOIN [$(OGDW_AM)].[dbo].[IN_CLD_Incident_ClosureDate] C ON IN_NUM_IN_ID = C.[IN_CLD_IN_ID]
	JOIN [$(OGDW_AM)].dbo.[IN_CHD_Incident_ChangeDate] D ON IN_NUM_IN_ID = D.IN_CHD_IN_ID
	JOIN [log].[Audit] ON Metadata_IN_NUM = AuditDWKey
WHERE 1=1
	AND IN_CLD_Incident_ClosureDate IS NULL
	AND SourceType = 'File'
	AND TargetName = '[FileImport].[Incidents]'
	-- Voor FloraHolland filteren we alle meldingen van voor 30 april 2016 uit deze view. Die meldingen worden niet langer geimporteerd
	AND NOT (SourceDatabaseKey = 323 AND D.IN_CHD_Incident_ChangeDate < '2016-04-30')
)  

, FindAuditDWKey AS
(
SELECT
	a2.SourceDatabaseKey
	, MaxAuditDWKey = MAX(a2.AuditDWKey)
FROM
	[log].[Audit] a2
WHERE 1=1
	AND a2.SourceType = 'File'
	AND a2.TargetName = '[FileImport].[Incidents]'
	AND a2.deleted = 0
GROUP BY
	a2.SourceDatabaseKey 
)

, MeldingenInLatestFileimport AS
(
SELECT
	IncidentNumber
	, SourceDatabaseKey
FROM
	[$(OGDW_Staging)].FileImport.Incidents I
	JOIN FindAuditDWKey fak ON fak.MaxAuditDWKey = I.AuditDWKey
)

, MissingInc AS
(
SELECT * FROM OpenstaandInAM
EXCEPT
SELECT * FROM MeldingenInLatestFileimport
)

SELECT
	I.SourceDatabaseKey
	, SD.ConnectionName
	, I.[Missing Incidents]
FROM
	MissingInc I
	JOIN setup.SourceDefinition SD ON SD.Code = I.SourceDatabaseKey

/*
SELECT TOP 10 * FROM monitoring.MissingIncidents ORDER BY SourceDatabaseKey, [Missing Incidents]
*/