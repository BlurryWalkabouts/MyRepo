CREATE PROCEDURE [monitoring].[LoadCircularReferences]
AS
BEGIN

/*
MINT18081013
Constatering: Er zijn bij SDK 347 (PG) dd 30-08-2018 wijzigingen met activiteiten die onderling van elkaar afhankelijk zijn.
Gevolg: Door deze cirkelverwijzingen ontstaat er een oneindige loop, die de etl in feite onderuit trekt.
Oplossing: Deze moeten in deze procedure worden gedetecteerd en vervolgens worden weggefilterd in OGDW_Archive.etl.PointChangeActivity.

Todo:
- Dit wordt nu uitgevoerd voor het laden van Datamart. Het zou mooier zijn om dit te doen voor het laden van Archive, zodat deze niet vervuild wordt.
*/

TRUNCATE TABLE [$(OGDW_Archive)].monitoring.CircularReferences

INSERT INTO
	[$(OGDW_Archive)].monitoring.CircularReferences
	(
	DWDateCreated
	, AuditDWKey
	, SourceDatabaseKey
	, DatabaseLabel
	, SourceFileType
	, ChangeNumber
	, ActivityNumber
	, changeid
	)
SELECT
	a.DWDateCreated
	, a.AuditDWKey
	, a.SourceDatabaseKey
	, sd.DatabaseLabel
	, sd.SourceFileType
	, ChangeNumber = c.number
	, ActivityNumber = ca.number
	, changeid = c.unid
FROM
	[$(OGDW_Archive)].TOPdesk.changeactivity__dependency cad1
	INNER JOIN [$(OGDW_Archive)].TOPdesk.changeactivity__dependency cad2 ON cad1.headid = cad2.tailid AND cad1.tailid = cad2.headid AND cad1.SourceDatabaseKey = cad2.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.changeactivity ca ON cad1.headid = ca.unid AND cad1.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.change c ON ca.changeid = c.unid AND ca.SourceDatabaseKey = c.SourceDatabaseKey
	INNER JOIN [log].[Audit] a ON cad1.AuditDWKey = a.AuditDWKey
	LEFT OUTER JOIN setup.SourceDefinition sd ON a.SourceDatabaseKey = sd.Code

END