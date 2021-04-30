CREATE VIEW [monitoring].[MissingChanges]
AS

/* View die kijkt of er in het AM openstaande changes zijn die in de laaste File Import niet geimporteerd zijn
Gemaakt door Wouter Gielen 20151126 versie 1 */

WITH OpenstaandInAM AS
(
SELECT 
	[Missing Changes] = ChangeNumber
	, C.SourceDatabaseKey
--	, SourceName
FROM
	[$(OGDW_AM)].dbo.Current_Change C
	JOIN setup.SourceDefinition S ON S.Code = C.SourceDatabaseKey
WHERE 1=1
	AND COALESCE(EndDateExtChange,ClosureDateSimpleChange,CancelDateExtChange,RejectionDate,IIF(CurrentPhase LIKE 'Afgeronde uitgebreide wijzigin%',ImplDateExtChange,NULL)) IS NULL
	AND SourceType = 'File'
	AND SourceFileType = 'Changes'
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
	AND a2.TargetName = '[FileImport].[Changes]'
	AND a2.deleted = 0
GROUP BY
	a2.SourceDatabaseKey
)

, WijzigingenInLatestFileimport AS
(
SELECT
	Changenumber
	, SourceDatabaseKey
FROM
	[$(OGDW_Staging)].FileImport.[Changes] C
	JOIN FindAuditDWKey fak ON fak.MaxAuditDWKey = C.AuditDWKey
)

, MissingCha AS
(
SELECT * FROM OpenstaandInAM
EXCEPT
SELECT * FROM WijzigingenInLatestFileimport
)

SELECT
	C.SourceDatabaseKey
	, SD.ConnectionName
	, C.[Missing Changes]
FROM
	MissingCha C
	JOIN setup.SourceDefinition SD ON SD.Code = C.SourceDatabaseKey
WHERE 1=1
-- TIJDELIJKE FILTER VOOR TWEEDE KAMER LOKAAL! DIT MOET WEER WEGGEHAALD WORDEN
	AND SourceDatabaseKey <> 43

/*
SELECT TOP 10 * FROM monitoring.MissingChanges ORDER BY SourceDatabaseKey, [Missing Changes]
*/