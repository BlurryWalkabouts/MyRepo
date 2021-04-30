CREATE PROCEDURE [liftetl].[LoadLiftTemporalTable]
(
	@staging_schema sysname
	, @archive_schema sysname
	, @table sysname
	, @pkfield1 varchar(max) -- Primary key, hoort bij table
	, @LiftAuditDWKey int
	, @debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY
BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max) = ''

DECLARE @inserted int
DECLARE @deleted int
DECLARE @updated int
DECLARE @db sysname = '$(LIFT_Archive)' -- Zonder vierkante haken!

DECLARE @2partTableName sysname = QUOTENAME(@archive_schema) + '.' + QUOTENAME(@table)
DECLARE @3partTableName sysname = QUOTENAME(@db) + '.' + @2partTableName
--DECLARE @2partTableNameStripped sysname = REPLACE(REPLACE(QUOTENAME(@archive_schema) + '.' + QUOTENAME(@table),'[',''),']','')

/**************************************************************************************************
NIEUW RECORDS INSERTEN
**************************************************************************************************/

DECLARE @select nvarchar(max) = ''

SELECT
	@select += CONCAT(QUOTENAME(COLUMN_NAME), ',')
FROM
	[$(LIFT_Archive)].INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
	AND TABLE_SCHEMA = @archive_schema
	AND TABLE_NAME = @table
	AND COLUMN_NAME NOT IN ('AuditDWKey', 'ValidFrom', 'ValidTo')

-- remove last comma
SET @select = REVERSE(SUBSTRING(REVERSE(@select), 2, LEN(@select)))

-- creates code to import new not known rows
-- Nieuwe Records Toevoegen 
SET @SQLString = '
	INSERT INTO
		' + @3partTableName + '
		(
		' + @select + '
		, AuditDWKey
		)
	SELECT
		' + REPLACE(@select, ',', ', I.') + '
		, A1.LiftAuditdwKey
	FROM
		[$(LIFT_Staging)].' + @staging_schema + '.' + @table + ' I
		JOIN [log].LiftAudit A1 ON I.AuditDWKey = A1.LiftAuditDWKey AND A1.deleted = 0
	WHERE 1=1
		AND I.AuditDWKey = ' + CAST(@LiftAuditDWKey AS varchar(10)) + '
		AND I.' + @pkfield1 + ' IS NOT NULL
		AND NOT EXISTS (
			SELECT
				' + REPLACE(@select, ',', ', T.') + '
				, T.AuditDWKey
			FROM
				' + @3partTableName + ' T
				JOIN [log].LiftAudit A2 ON T.AuditDWKey = A2.LiftAuditDWKey AND A2.deleted = 0
			WHERE 1=1
				AND I.' + @pkfield1 + ' = T.' + @pkfield1 + '
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
SET @SQLString = 'IF OBJECT_ID(''tempdb..##deletedTable'') IS NULL CREATE TABLE ##deletedTable (' + @pkfield1 + ' varchar(max), LiftAuditDWKey int)'

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
		JOIN [log].LiftAudit A1 ON T.AuditDWKey = A1.LiftAuditDWKey AND A1.deleted = 0
	WHERE 1=1
		AND NOT EXISTS (
			SELECT
				*
			FROM
				[$(LIFT_Staging)].' + @staging_schema + '.' + @table + ' I
				JOIN [log].LiftAudit A2 ON I.AuditDWKey = A2.LiftAuditDWKey AND A2.deleted = 0
			WHERE 1=1
				AND I.' + @pkfield1 + ' = T.' + @pkfield1 + ' 
				AND I.AuditDWKey = ' + CAST(@LiftAuditDWKey AS char) + '
			)'

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

SET @deleted = @@ROWCOUNT

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
		' + @select + '
	FROM
		[$(LIFT_Staging)].' + @staging_schema + '.' + @table + ' I1
		JOIN [log].LiftAudit A ON I1.AuditDWKey = A.LiftAuditDWKey AND A.deleted = 0
	WHERE 1=1
		AND I1.AuditDWKey = ' + CAST(@LiftAuditDWKey AS varchar(10)) + '
	EXCEPT
	SELECT
		' + @select + '
	FROM
		' + @3partTableName + ' I1
		JOIN [log].LiftAudit A1 ON I1.AuditDWKey = A1.LiftAuditDWKey AND A1.deleted = 0
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
	@select += CONCAT('T.', QUOTENAME(COLUMN_NAME) , ' = I.', QUOTENAME(COLUMN_NAME) , ',')
FROM
	[$(LIFT_Archive)].INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
	AND TABLE_SCHEMA = @archive_schema 
	AND TABLE_NAME = @table 
	AND COLUMN_NAME NOT IN ('ValidFrom', 'ValidTo')

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
		' + @db + '.' + @archive_schema + '.' + @table + ' T
		JOIN [$(LIFT_Staging)]' + '.' + @staging_schema + '.' + @table + ' I ON I.' + @pkfield1 + ' = T.' + @pkfield1 + ' AND I.AuditDWKey = ' + CAST(@LiftAuditDWKey as varchar(10)) + '
		JOIN [log].LiftAudit A ON I.AuditDWKey = A.LiftAuditDWKey AND A.deleted = 0
		JOIN (SELECT * FROM ##changed) changed ON changed.' + @pkfield1 + ' = I.' + @pkfield1

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

SET @updated = @@ROWCOUNT

DECLARE @msg nvarchar(max)

SET @msg = CONCAT('Finished loading Table ', @table, ' ' , @LiftAuditDWKey, ', ')
SET @msg += CONCAT('Rows inserted: ', @inserted, ', ')
SET @msg += CONCAT('Rows updated: ', @updated, ', ')
SET @msg += CONCAT('Rows deleted: ', @deleted, '. ')

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