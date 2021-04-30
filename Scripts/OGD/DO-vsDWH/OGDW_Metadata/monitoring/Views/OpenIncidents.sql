CREATE VIEW [monitoring].[OpenIncidents]
AS

/* View die kijkt of er in Archive openstaande incidenten zijn die in de laatste FileImport niet beschikbaar zijn */

WITH IncidentsInStaging AS
(
SELECT
	a.SourceDatabaseKey
	, i.IncidentNumber
FROM
	[$(OGDW_Staging)].FileImport.Incidents i
	LEFT OUTER JOIN [log].[Audit] a ON i.AuditDWKey = a.AuditDWKey
)

SELECT 
	i.SourceDatabaseKey
	, sd.DatabaseLabel
	, i.IncidentNumber
--	, i.ClosureDate
	, i.[Status]
	, a.AuditDWKey
	, a.DWDateCreated
	, RecentlyImported = CASE WHEN d.SourceDatabaseKey IS NOT NULL THEN 1 ELSE 0 END
FROM
	[$(OGDW)].Fact.Incident i
	LEFT OUTER JOIN IncidentsInStaging s ON i.IncidentNumber = s.IncidentNumber AND i.SourceDatabaseKey = s.SourceDatabaseKey
	LEFT OUTER JOIN (SELECT DISTINCT SourceDatabaseKey FROM IncidentsInStaging) d ON i.SourceDatabaseKey = d.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceDefinition sd ON i.SourceDatabaseKey = sd.Code
	LEFT OUTER JOIN [log].[Audit] a ON i.AuditDWKey = a.AuditDWKey
WHERE 1=1
	AND s.IncidentNumber IS NULL
	AND sd.SourceType = 'FILE'
	AND i.ClosureDate IS NULL