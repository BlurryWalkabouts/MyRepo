CREATE PROCEDURE [liftsetup].[TransferSchemaStagingTables]
(
	@debug bit = 0
)
AS
BEGIN

/* Deze procedure hernoemt het schema van alle tabellen in LIFT_Staging naar de laatste Lift versie */

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)
DECLARE @old_staging_schema sysname = (SELECT [SCHEMA_NAME] FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.SCHEMATA WHERE [SCHEMA_NAME] LIKE 'Lift%')
DECLARE @new_staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))

-- Maak het nieuwe schema aan
SET @SQLString = '[$(LIFT_Staging)]..sp_executesql N''CREATE SCHEMA [' + @new_staging_schema + '] AUTHORIZATION dbo;'''

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

-- Verplaats alle tabellen naar het nieuwe schema
DECLARE ExecuteBatches CURSOR FOR
(
SELECT
	SQLString = '[$(LIFT_Staging)]..sp_executesql N''ALTER SCHEMA [' + @new_staging_schema + '] TRANSFER [' + s.[SCHEMA_NAME] + '].[' + t.TABLE_NAME + '];'''
FROM
	[$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES t
	INNER JOIN [$(LIFT_Staging)].INFORMATION_SCHEMA.SCHEMATA s ON t.TABLE_SCHEMA = s.[SCHEMA_NAME]
WHERE 1=1
	AND s.[SCHEMA_NAME] = @old_staging_schema
)
ORDER BY
	t.TABLE_NAME

OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @SQLString

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @debug = 0
		EXEC (@SQLString)
	ELSE
		PRINT @SQLString

	FETCH NEXT FROM ExecuteBatches INTO @SQLString
END

CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

-- Verwijder het oude schema
SET @SQLString = '[$(LIFT_Staging)]..sp_executesql N''DROP SCHEMA [' + @old_staging_schema + '];'''

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

END