CREATE PROCEDURE [etl].[LoadTemporalTable]
(
	@schema sysname
	, @table sysname
	, @pkfield1 varchar(max) -- Primary key, hoort bij table
	, @AuditDWKey int
	, @debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY
BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max)

DECLARE @inserted int
DECLARE @deleted int
DECLARE @updated int
DECLARE @db sysname = '$(OGDW_Archive)' -- Zonder vierkante haken!
DECLARE @sdk int = (SELECT DISTINCT CAST(SourceDatabaseKey AS int) FROM [log].[Audit] WHERE AuditDWKey = @AuditDWKey)

DECLARE @2partTableName sysname = QUOTENAME(@schema) + '.' + QUOTENAME(@table)
DECLARE @3partTableName sysname = QUOTENAME(@db) + '.' + @2partTableName
--DECLARE @2partTableNameStripped sysname = REPLACE(REPLACE(QUOTENAME(@schema) + '.' + QUOTENAME(@table),'[',''),']','')

-- In geval van delta imports moeten we voorkomen dat de data uit de parent tabel van de temporal table wordt verwijderd omdat enkel de wijzigingen
-- worden geimporteerd. Alles wat niet in de delta import zit zal er voor zorgen dat het in de temporal table als history wordt vastgelegd. Dit voorkomen
-- we met de volgende parameter
/*
DECLARE @delta int

;WITH w AS
(
SELECT
	cnt = CASE WHEN SourceType = 'mssql' THEN 1 ELSE 0 END
FROM
	[log].[Audit]
WHERE 1=1
	AND AuditDWKey = @AuditDWKey
UNION ALL
SELECT
	cnt = 1
FROM
	[$(OGDW_Staging)].INFORMATION_SCHEMA.TABLES t
WHERE 1=1
	AND t.TABLE_SCHEMA = 'TOPdesk'
	AND t.TABLE_NAME = @table
	AND t.TABLE_NAME NOT IN (
		SELECT DISTINCT c.TABLE_NAME
		FROM [$(OGDW_Staging)].INFORMATION_SCHEMA.COLUMNS c
		WHERE c.COLUMN_NAME = 'datwijzig' AND c.TABLE_SCHEMA = 'TOPdesk'
	)
)

SELECT @delta = ISNULL(SUM(cnt),0) FROM w

IF (SELECT SourceType FROM [log].[Audit] a WHERE a.AuditDWKey = @AuditDWKey) = 'XML' -- Deze check is niet eens nodig
*/
	
DECLARE @delta int = 0

IF EXISTS (
	SELECT
		COLUMN_NAME
	FROM
		[$(OGDW_Staging)].INFORMATION_SCHEMA.COLUMNS C
		JOIN [$(OGDW_Staging)].INFORMATION_SCHEMA.TABLES T ON C.TABLE_NAME = T.TABLE_NAME AND C.TABLE_SCHEMA = T.TABLE_SCHEMA
	WHERE 1=1
		AND c.TABLE_SCHEMA = @schema
		AND c.TABLE_NAME = @table
		AND c.COLUMN_NAME = 'datwijzig' 
		AND t.TABLE_TYPE = 'BASE TABLE'
	)
BEGIN
	IF @debug = 1 PRINT 'Checking [datwijzig]' 	

	-- Check of er oudere data in batch zit:
	DECLARE @t_staging datetime
	DECLARE @t_archive datetime 

	SET @SQLString = 'SELECT @t = MIN(datwijzig) FROM [$(OGDW_Staging)].' + @2partTableName + ' WHERE AuditDWKey = ' + CAST(@AuditDWKey AS varchar(max)) + ';'
--	PRINT @SQLString

	EXEC sp_executesql @SQLString, N'@t datetime OUTPUT', @t = @t_staging OUTPUT

	SET @SQLString = 'SELECT @t = MAX(datwijzig) FROM ' + @db + '.' + @2partTableName + ' WHERE SourceDatabaseKey = ' + CAST(@sdk AS varchar(max)) + ';'
--	PRINT @SQLString

	EXEC sp_executesql @SQLString, N'@t datetime OUTPUT', @t = @t_archive OUTPUT
	
	-- Klein beetje overlap is wel mogelijk, meer dan een paar uur niet bij een delta. Lege batch wordt als delta beschouwd (zodat er niks verwijderd wordt)
	IF ISNULL(@t_staging,'21990101') > DATEADD(HH, -12, ISNULL(@t_archive,'19000101'))
		SET @delta = 1

	IF @debug = 1 PRINT 'MAX(datwijzig) FROM Archive: ' + ISNULL(CAST(@t_archive AS varchar(max)),'-')
	IF @debug = 1 PRINT 'MIN(datwijzig) FROM Staging: ' + ISNULL(CAST(@t_staging AS varchar(max)),'-')
	IF @debug = 1 PRINT 'Delta: ' + CAST(@delta AS varchar(max))
END

/**************************************************************************************************
NIEUW RECORDS INSERTEN
**************************************************************************************************/

DECLARE @select nvarchar(max) = ''

SELECT
	@select += CONCAT(COLUMN_NAME, ',')
FROM
	[$(OGDW_Archive)].INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
	AND TABLE_SCHEMA = @schema 
	AND TABLE_NAME = @table
	AND COLUMN_NAME NOT IN ('SourceDatabaseKey', 'AuditDWKey', 'ValidFrom', 'ValidTo')
	-- SDK en AuditDWKey weghalen omdat deze wel in TOPdesk zitten, maar niet in Fileimport. ValidFrom en ValidTo wordt automatisch gevuld
	-- Hieronder worden de kolommen weer toegevoegd

SET @select = REVERSE(SUBSTRING(REVERSE(@select), 2, LEN(@select)))

-- Nieuwe records toevoegen 
SET @SQLString = '
	INSERT INTO
		' + @3partTableName + '
		(
		' + @select + '
		, AuditDWKey
		, SourceDatabaseKey
		)
	SELECT
		' + REPLACE(@select, ',', ', I.') + '
		, A1.AuditDWKey
		, A1.SourceDatabaseKey 
	FROM
		[$(OGDW_Staging)].' + @2partTableName + ' I
		JOIN [log].[Audit] A1 ON I.AuditDWKey = A1.AuditDWKey AND A1.deleted = 0
	WHERE 1=1
		AND I.AuditDWKey = ' + CAST(@AuditDWKey AS varchar(10)) + '
		AND I.' + @pkfield1 + ' IS NOT NULL
		AND NOT EXISTS (
			SELECT
				' + REPLACE(@select, ',', ', T.') + '
				, T.AuditDWKey
				, A2.SourceDatabaseKey
			FROM
				' + @3partTableName + ' T
				JOIN [log].[Audit] A2 ON T.AuditDWKey = A2.AuditDWKey AND A2.deleted = 0
			WHERE 1=1
				AND I.' + @pkfield1 + ' = T.' + @pkfield1 + '
				AND A2.SourceDatabaseKey = ' + CAST(@sdk AS varchar(max)) + '
			)'

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

SET @inserted = @@ROWCOUNT

/*********************************************************************************
Niet meer bestaande records verwijderen:
*********************************************************************************/

-- Create temp tabel ##deleted
SET @SQLString = 'IF OBJECT_ID(''tempdb..##deletedTable'') IS NULL CREATE TABLE ##deletedTable (' + @pkfield1 + ' varchar(max), AuditDWKey int)'

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

-- Drop temp tabel ##changed
SET @SQLString = 'DROP TABLE IF EXISTS ##changed'

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

/* Dit doen we niet meer omdat dit zorgt voor parent records die onterecht worden gearchiveerd

-- ******************** skip delete if @delta <> 0 *********************

IF @delta = 0
BEGIN
	-- Niet meer bestaande records verwijderen uit PARENT tabel
	SET @SQLString = '
	DELETE
		T
	OUTPUT
		deleted.' + @pkfield1 + '
		, deleted.AuditDWKey
	INTO
		##deletedTable
	FROM
		' + @3partTableName + ' T
		JOIN [log].[Audit] A1 ON T.AuditDWKey = A1.AuditDWKey AND A1.deleted = 0
	WHERE 1=1
		AND A1.SourceDatabaseKey = ' + CAST(@sdk AS varchar(max)) + '
		AND NOT EXISTS (
			SELECT
				*
			FROM
				[$(OGDW_Staging)].' + @2partTableName + ' I
				JOIN [log].[Audit] A2 ON I.AuditDWKey = A2.AuditDWKey AND A2.deleted = 0
			WHERE 1=1
				AND I.' + @pkfield1 + ' = T.' + @pkfield1 + ' COLLATE SQL_Latin1_General_CP1_CS_AS
				AND I.AuditDWKey = ' + CAST(@AuditDWKey AS char) + '
				AND A2.SourceDatabaseKey = ' + CAST(@sdk AS varchar(max)) + '
			);'

	IF @debug = 0
		EXEC (@SQLString)
	ELSE
		PRINT @SQLString

	SET @deleted = @@ROWCOUNT
END
*/
/*********************************************************************************
UPDATE RECORDS DIE OPNIEUW WORDEN GEIMPORTEERD
*********************************************************************************/

/*
Onderstaande code genereert een except query waardoor enkel recs die veranderen worden meegenomen.
QUICKFIX in de SELECT van de CTE wordt status verwijderd omdat deze ook in de audit tabel zit. Ambigious anders...
*/

SET @SQLString = '
	-- cte gebruikt EXCEPT om selectie te maken van alles dat verandert
	WITH wrapper AS
	(
	SELECT
		' + REPLACE(@select, ',status', ',I1.status') + '
	FROM
		[$(OGDW_Staging)].' + @2partTableName + ' I1
		JOIN [log].[Audit] A ON I1.AuditDWKey = A.AuditDWKey AND A.deleted = 0
	WHERE 1=1
		AND I1.AuditDWKey = ' + CAST(@AuditDWKey AS varchar(10)) + '
	EXCEPT
	SELECT
		' + REPLACE(@select, ',status', ',I1.status') + '
	FROM
		' + @3partTableName + ' I1
		JOIN [log].[Audit] A1 ON I1.AuditDWKey = A1.AuditDWKey AND A1.deleted = 0
	WHERE 1=1
		AND A1.SourceDatabaseKey = ' + CAST(@sdk AS varchar(max)) + '
	)

	, cte AS
	(
	SELECT
		' + @pkfield1 + '
	FROM
		wrapper
	)

	SELECT
		*
	INTO
		##changed
	FROM
		cte'

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

/* 
Onderstaande genereert update query met @select aan de hand van ##changed 
*/

SET @select = ''

SELECT
	@select += CONCAT('T.', COLUMN_NAME, ' = I.', COLUMN_NAME, ',')
FROM
	[$(OGDW_Archive)].INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
	AND TABLE_SCHEMA = @schema
	AND TABLE_NAME = @table
	AND COLUMN_NAME NOT IN ('SourceDatabaseKey', 'ValidFrom', 'ValidTo')

-- Laatste komma verwijderen
SET @select = REVERSE(SUBSTRING(REVERSE(@select), 2, LEN(@select)-1))

-- Selectie uit ##changed updaten en alle gevallen opslaan in ##deleted
SET @SQLString = '
	UPDATE
		T
	SET
		' + @select + '
	OUTPUT
		deleted.' + @pkfield1 + '
		, deleted.AuditDWKey
	INTO
		##deletedTable -- SDK toevoegen!
	FROM
		' + @db + '.' + @schema +'.' + @table + ' T
		JOIN [$(OGDW_Staging)]' + '.' + @schema + '.' + @table + ' I ON I.' + @pkfield1 + ' = T.' + @pkfield1 + ' AND I.AuditDWKey = ' + CAST(@AuditDWKey AS varchar(10)) + '
		JOIN [log].[Audit] A ON I.AuditDWKey = A.AuditDWKey AND A.deleted = 0
		JOIN (SELECT * FROM ##changed) changed ON changed.' + @pkfield1 + ' = I.' + @pkfield1 + '
	WHERE 1=1
		AND A.SourceDatabaseKey = ' + CAST(@sdk AS varchar(max)) + '
		AND A.SourceDatabaseKey = T.SourceDatabaseKey'

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

SET @updated = @@ROWCOUNT

DECLARE @msg nvarchar(max)

SET @msg = CONCAT('Finished loading Table ', @table, ' ', @sdk, ' ', @AuditDWKey, ', ')
SET @msg += CONCAT('Rows inserted: ', @inserted, ', ')
SET @msg += CONCAT('Rows updated: ', @updated, ', ')
SET @msg += CASE WHEN @delta = 1 THEN 'DELETE skipped due to delta import' ELSE CONCAT('Rows deleted: ', @deleted, '. ') END

RAISERROR(@msg, 0, 1) WITH NOWAIT

-- Drop temp tables
SET @SQLString = 'DROP TABLE IF EXISTS ##deletedTable, ##changed'

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

COMMIT TRANSACTION
END TRY

BEGIN CATCH
	THROW
	ROLLBACK TRANSACTION
END CATCH

END

/*
-- CREATES BATCH 
SELECT SourceDatabaseKey FROM [log].[Audit] a WHERE AuditDWKey = 14889

SELECT DISTINCT
	a.SourceDatabaseKey
	, a.AuditDWKey
	, CONCAT('EXEC [etl].[LoadTemporalTable] ', a.AuditDWKey)
FROM [log].[Audit] a
--	JOIN [$(OGDW_Staging)].FileImport.incidents i ON i.AuditDWKey = a.AuditDWKey
--	JOIN INFORMATION_SCHEMA is ON is.
WHERE 1=1
	AND a.SourceDatabaseKey = 11
ORDER BY
	a.SourceDatabaseKey
	, a.AuditDWKey

EXEC etl.LoadTemporalTable
	'FileImport'
	, 'Changes'
	, 'ChangeNumber' -- Primary key, hoort bij tabel
	, 14889 -- Beweging3
	, 1

EXEC etl.LoadTemporalTable
	'FileImport'
	, 'Incidents'
	, 'IncidentNumber' -- Primary key, hoort bij tabel
	, 14891 -- Interfood
	, 1

EXEC etl.LoadTemporalTable 
	'TOPdesk'
	, 'change'
	, 'unid'
	, 18470 -- MKBO
	, 1

EXEC etl.LoadTemporalTable 
	'TOPdesk'
	, 'incident'
	, 'unid'
	, '15158' -- KVDL
	, 1
*/