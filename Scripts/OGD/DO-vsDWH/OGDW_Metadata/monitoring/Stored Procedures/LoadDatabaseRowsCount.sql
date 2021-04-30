CREATE PROCEDURE [monitoring].[LoadDatabaseRowsCount]
(
	@fact nvarchar(16)
	, @debug bit = 0
)
AS 

BEGIN

SET NOCOUNT ON

-- Er zijn maar vier relevante fact tabellen
SET @fact = CASE WHEN @fact NOT IN ('Incident','Change','ChangeActivity','Problem') THEN 'Incident' ELSE @fact END

-- Naam van corresponderende tabel voor DB imports in OGDW_Archive
DECLARE @table nvarchar(16) = REPLACE(LOWER(@fact),'problem','probleem')
-- Kolom op basis waarvan het aantal rijen geteld wordt (behalve bij DB imports in OGDW_Archive, gebruik dan unid)
DECLARE @businesskey nvarchar(16) = REPLACE(@fact,'ChangeActivity','Activity') + 'Number'

-- Tel het aantal rijen per database per SDK en zet deze in een #tabel (is in dit geval veel sneller dan een cte)
DECLARE @SQLString nvarchar(max) = '
SELECT *
INTO #DWHRowsCount
FROM
(
SELECT
	DatabaseName = ''ArchiveHistory''
	, SourceDatabaseKey
	, RowsCount = COUNT(unid)
FROM
	(
	SELECT SourceDatabaseKey, unid FROM [$(OGDW_Archive)].TOPdesk.' + @table + '
	UNION
	SELECT SourceDatabaseKey, unid FROM [$(OGDW_Archive)].history.' + @table + '
	) x
GROUP BY
	SourceDatabaseKey'
+ CASE WHEN @fact IN ('Incident','Change') THEN '
UNION
SELECT
	DatabaseName = ''ArchiveHistory''
	, SourceDatabaseKey
	, RowsCount = COUNT(' + @businesskey + ')
FROM
	(
	SELECT SourceDatabaseKey, ' + @businesskey + ' FROM [$(OGDW_Archive)].fileimport.' + @table + 's
	UNION
	SELECT SourceDatabaseKey, ' + @businesskey + ' FROM [$(OGDW_Archive)].history.' + @table + 's
	) x
GROUP BY
	SourceDatabaseKey' ELSE '' END + '

UNION

SELECT
	DatabaseName = ''ArchiveParent''
	, SourceDatabaseKey
	, RowsCount = COUNT(unid)
FROM
	[$(OGDW_Archive)].TOPdesk.' + @table + '
GROUP BY
	SourceDatabaseKey'
+ CASE WHEN @fact IN ('Incident','Change') THEN '
UNION
SELECT
	DatabaseName = ''ArchiveParent''
	, SourceDatabaseKey
	, RowsCount = COUNT(' + @businesskey + ')
FROM
	[$(OGDW_Archive)].fileimport.' + @table + 's
GROUP BY
	SourceDatabaseKey' ELSE '' END + '

UNION

SELECT
	DatabaseName = ''TOPdesk_DW''
	, SourceDatabaseKey
	, RowsCount = COUNT(' + @businesskey + ')
FROM
	[$(OGDW)].Fact.' + @fact + '
GROUP BY
	SourceDatabaseKey
) DWHRowsCount
' +
/* Zoek op voor welke SDK rijen worden verwacht en zorg ervoor dat per database een waarde wordt weergegeven */ + '
SELECT
	MonitoringDate = GETDATE()
	, Fact = ''' + @fact + '''
	, DatabaseName = db.DatabaseName
	, SourceDatabaseKey = sd.Code
	, RowsCount = COALESCE(rc.RowsCount,0)
FROM
	setup.SourceDefinition sd
	CROSS JOIN (SELECT DISTINCT DatabaseName FROM #DWHRowsCount) db
	LEFT OUTER JOIN #DWHRowsCount rc ON sd.Code = rc.SourceDatabaseKey AND db.DatabaseName = rc.DatabaseName
WHERE 1=1
	AND [Enabled] = 1'
+ CASE WHEN @fact IN ('Incident','Change') THEN '
	AND Import' + @fact + 's = 1' ELSE '
	AND SourceType IN (''MSSQL'',''XML'')' END

IF @debug = 0
	INSERT INTO monitoring.DatabaseRowsCount
	(
		MonitoringDate
		, Fact
		, DatabaseName
		, SourceDatabaseKey
		, RowsCount
	)
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

END