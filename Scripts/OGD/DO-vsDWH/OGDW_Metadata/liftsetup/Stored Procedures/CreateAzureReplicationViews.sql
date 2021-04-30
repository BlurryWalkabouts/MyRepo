CREATE PROCEDURE [liftsetup].[CreateAzureReplicationViews]
(
	@debug bit = 1
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)
DECLARE @staging_schema sysname = 'dwh'
DECLARE @filename sysname = ''
		
/*
Create dwh-views for Lift-SaaS ..?
*/

DECLARE c CURSOR FOR
(
SELECT TABLE_NAME
FROM [$(LIFT_Staging)].setup.DWTables_Azure
WHERE import = 1
)
ORDER BY TABLE_NAME

DECLARE @table_name sysname

OPEN c
FETCH NEXT FROM c INTO @table_name
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT '--Creating view: ' + @staging_schema + '.' + QUOTENAME(@table_name)
	SET @SQLString = ''

	/* Create new view */
	SET @SQLString += 'SET ANSI_NULLS ON' + CHAR(10)
	SET @SQLString += 'GO' + CHAR(10)

	SET @SQLString += 'SET QUOTED_IDENTIFIER ON' + CHAR(10)
	SET @SQLString += 'GO' + CHAR(10)
	
	SET @SQLString += 'DROP VIEW IF EXISTS ' + @staging_schema + '.' + QUOTENAME(@table_name) + CHAR(10)
	SET @SQLString += 'GO' + CHAR(10)

	SET @SQLString += 'CREATE VIEW ' + @staging_schema + '.' + QUOTENAME(@table_name) + CHAR(10)
	SET @SQLString += 'AS' + CHAR(10)
	SET @SQLString += 'SELECT' + CHAR(10)

	SELECT
		@SQLString += CHAR(9) + QUOTENAME(COLUMN_NAME) /* + column_fulltype */ + ',' + CHAR(10)
	FROM
		[$(LIFT_Staging)].setup.DWColumns_Azure
	WHERE 1=1
		AND import = 1
		AND TABLE_NAME = @table_name
	ORDER BY
		COLUMN_NAME

	SET @SQLString = LEFT(@SQLString,LEN(@SQLString)-2)
	SET @SQLString += CHAR(10)
	SET @SQLString += 'FROM' + CHAR(10)
	SET @SQLString += CHAR(9) + 'dbo.' + QUOTENAME(@table_name) + ';' + CHAR(10)
	SET @SQLString += 'GO' + CHAR(10)

	IF @debug = 0
		EXEC (@SQLString)
	ELSE
		BEGIN
			PRINT @SQLString
			SET @filename = @table_name + '.sql'
		--	EXEC [00_METADATA].dbo.usp_WriteStringToFile @SQLString, 'C:\Temp', @filename
		END

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