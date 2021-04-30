CREATE PROCEDURE [etl].[GenerateBatch]
(
	@schema sysname
	, @table sysname
	, @pkfield1 varchar(max) = 'unid'
	, @debug bit = 0
)
AS
BEGIN

DECLARE @SQLString nvarchar(max) = '
--DROP TABLE IF EXISTS #MaxAuditDWKey
CREATE TABLE #MaxAuditDWKey (SourceDatabaseKey int, AuditDWKey int)
' +
/* Zoek alle AuditDWKeys op in OGDW_Archive (parent en history) èn voeg voor iedere SDK een basis AuditDWKey van 1 toe. Dit
laatste is nodig omdat deze CTE anders leeg blijft voor nieuwe tabellen en vervolgens het volledige resultaat van deze
procedure ook leeg zal zijn. */ + '
;WITH SdkInHistory AS
(
SELECT DISTINCT
	SourceDatabaseKey = Code
	, AuditDWKey = 1
FROM
	setup.SourceDefinition
WHERE 1=1
	AND SourceType IN (''MSSQL'',''XML'')
UNION
SELECT DISTINCT
	SourceDatabaseKey
	, AuditDWKey
FROM
	[$(OGDW_Archive)].' + @schema + '.' + @table + '
UNION
SELECT DISTINCT
	SourceDatabaseKey
	, AuditDWKey
FROM
	[$(OGDW_Archive)].history.' + @table + '
)
' +
/* Zoek per bron de meest recente AuditDWKey */ + '
INSERT INTO
	#MaxAuditDWKey (SourceDatabaseKey, AuditDWKey)
SELECT
	SourceDatabaseKey
	, AuditDWKey = ISNULL(MAX(AuditDWKey),0)
FROM
	SdkInHistory
GROUP BY
	SourceDatabaseKey
' +
/* Maak een statement aan voor alle nieuwere (cq ontbrekende) batches. Vergelijk hiervoor met de meest recente AuditDWKey.
Als er voor een bron geen AuditDWKeys te vinden zijn in OGDW_Archive, neem dan alle batches */ + '
SELECT DISTINCT
	Sproc = CONCAT(''EXEC etl.LoadTemporalTable '', ''''''' + @schema + ''''', '', ''''''' + @table + ''''', '', ''''''' + @pkfield1 + ''''', '', a.AuditDWKey, '';'')
	, SourceDatabaseKey = a.SourceDatabaseKey
	, AuditDWKey = a.AuditDWKey
FROM
	#MaxAuditDWKey x
	INNER JOIN [log].[Audit] a
		ON (a.SourceDatabaseKey = x.SourceDatabaseKey AND a.AuditDWKey > x.AuditDWKey)' +
/*
Wanneer een klant nog niet in OGDW_Archive is verwerkt kan geen vergelijking met de meest recent verwerkte batch
worden gedaan (want hij bestaat niet). Hierom worden deze gevallen apart behandeld in de join op OGDW_Metadata
met 'NOT IN #MaxAuditDWKey' zodat ook deze batches worden meegenomen. Trello ticket https://trello.com/c/fKs9n28p
*/ + '
		OR a.SourceDatabaseKey NOT IN (SELECT SourceDatabaseKey FROM #MaxAuditDWKey)
	LEFT OUTER JOIN setup.SourceDefinition sd ON a.SourceDatabaseKey = sd.Code
WHERE 1=1
	AND a.DWDateCreated > DATEADD(DD,-5,GETDATE())' + /* Want oudere data staat niet meer in staging? (MV) */ + '
	AND sd.SourceFileType = ''' + CASE WHEN @schema = 'FileImport' THEN @table ELSE 'Default' END + '''
ORDER BY
	a.AuditDWKey
	, a.SourceDatabaseKey'

IF @debug = 0
	INSERT INTO etl.GenerateBatchForArchive 
	(
		Sproc
		, SourceDatabaseKey
		, AuditDWKey
	)
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

END

/*
EXEC etl.GenerateBatch 'FileImport', 'Incidents', 'incidentnumber', 1
EXEC etl.GenerateBatch 'FileImport', 'Changes', 'changenumber', 1
EXEC etl.GenerateBatch 'TOPdesk', 'actiedoor', 'unid', 1
EXEC etl.GenerateBatch 'TOPdesk', 'change', 'unid', 1
EXEC etl.GenerateBatch 'TOPdesk', 'changeactivity', 'unid', 1
EXEC etl.GenerateBatch 'TOPdesk', 'incident', 'unid', 1
EXEC etl.GenerateBatch 'TOPdesk', 'probleem', 'unid', 1
EXEC etl.GenerateBatch 'TOPdesk', 'vrijeopzoekvelden', 'unid', 1
*/