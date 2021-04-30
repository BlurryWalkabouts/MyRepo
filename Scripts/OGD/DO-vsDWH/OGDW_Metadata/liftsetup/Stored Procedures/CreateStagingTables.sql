CREATE PROCEDURE [liftsetup].[CreateStagingTables]
(
	@debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)
DECLARE @staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))

/* Create schema */
SET @SQLString = N'CREATE SCHEMA ' + @staging_schema

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

DECLARE c CURSOR FOR
(
SELECT TABLE_NAME
FROM [$(LIFT_Staging)].setup.DWTables
WHERE import = 1
)
ORDER BY TABLE_NAME

DECLARE @table_name sysname

OPEN c
FETCH NEXT FROM c INTO @table_name
WHILE @@FETCH_STATUS = 0
BEGIN
	/* Drop current table */
	PRINT 'Dropping table: ' + @staging_schema + '.' + @table_name+ ' if it exists'

	SET @SQLString = 'DROP TABLE IF EXISTS [$(LIFT_Staging)].' + @staging_schema + '.' + @table_name

	IF @debug = 0
		EXEC (@SQLString)
	ELSE
		PRINT @SQLString

	/* Create new table */
	PRINT 'Creating table: ' + @staging_schema + '.' + @table_name

	SET @SQLString = 'CREATE TABLE ' + @staging_schema + '.' + @table_name + CHAR(10) + '('

	SELECT
		@SQLString += CHAR(10) + CHAR(9) + QUOTENAME(COLUMN_NAME) + ' ' + column_fulltype + ','
	FROM
		[$(LIFT_Staging)].setup.DWColumns
	WHERE 1=1
		AND import = 1
		AND TABLE_NAME = @table_name

	SET @SQLString += CHAR(10) + CHAR(9) + '[AuditDWKey] int' + CHAR(10) + ')'

	IF @debug = 0
		EXEC (@SQLString)
	ELSE
		PRINT @SQLString

	FETCH NEXT FROM c INTO @table_name
END

CLOSE c
DEALLOCATE c

END

/*
--Opruimen:

SELECT
	'DROP TABLE Lift212.' + TABLE_NAME
FROM
	INFORMATION_SCHEMA.TABLES
WHERE 1=1
	AND TABLE_SCHEMA = 'Lift212'  --> uitvoeren

DROP SCHEMA Lift212
*/