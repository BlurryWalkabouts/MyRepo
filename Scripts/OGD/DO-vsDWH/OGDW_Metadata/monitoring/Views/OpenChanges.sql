CREATE VIEW [monitoring].[OpenChanges]
AS

/* View die kijkt of er in Archive openstaande wijzigingen zijn die in de laatste FileImport niet beschikbaar zijn */

WITH ChangesInStaging AS
(
SELECT
	a.SourceDatabaseKey
	, c.ChangeNumber
FROM
	[$(OGDW_Staging)].FileImport.[Changes] c
	LEFT OUTER JOIN [log].[Audit] a ON c.AuditDWKey = a.AuditDWKey
)

SELECT 
	c.SourceDatabaseKey
	, sd.DatabaseLabel
	, c.ChangeNumber
--	, c.ClosureDate
	, c.CurrentPhase
	, c.[Status]
	, a.AuditDWKey
	, a.DWDateCreated
	, RecentlyImported = CASE WHEN d.SourceDatabaseKey IS NOT NULL THEN 1 ELSE 0 END
FROM
	[$(OGDW)].Fact.[Change] c
	LEFT OUTER JOIN ChangesInStaging s ON c.ChangeNumber = s.ChangeNumber AND c.SourceDatabaseKey = s.SourceDatabaseKey
	LEFT OUTER JOIN (SELECT DISTINCT SourceDatabaseKey FROM ChangesInStaging) d ON c.SourceDatabaseKey = d.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceDefinition sd ON c.SourceDatabaseKey = sd.Code
	LEFT OUTER JOIN [log].[Audit] a ON c.AuditDWKey = a.AuditDWKey
WHERE 1=1
	AND s.ChangeNumber IS NULL
	AND sd.SourceType = 'FILE'
	AND (1<>1
	OR c.ClosureDate IS NULL
--	OR c.CurrentPhase NOT IN ('Closed Extensive Change','Cancelled Extensive Change','Afgeronde uitgebreide wijziging','Afgewezen wijzigingsaanvraag','Geannuleerde uitgebreide wijziging')
--	OR c.[Status] NOT IN ('Closed')
	)