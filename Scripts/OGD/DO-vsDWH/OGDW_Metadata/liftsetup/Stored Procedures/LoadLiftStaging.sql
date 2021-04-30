CREATE PROCEDURE [liftsetup].[LoadLiftStaging]
AS
BEGIN

SET NOCOUNT ON

DECLARE @staging_schema sysname = (SELECT [SCHEMA_NAME] FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.SCHEMATA WHERE [SCHEMA_NAME] LIKE 'Lift%')
DECLARE @source_full_schema sysname = '[$(LIFTServer)].[$(LIFT5)].dbo'

-- Kolommen uit Lift opnieuw ophalen en toevoegen aan setup, kan nu vanuit FindDifferences

-- Types aanpassen
UPDATE [$(LIFT_Staging)].setup.DWColumns SET column_fulltype = 'nvarchar(max)', compare = 0 WHERE column_fulltype = 'ntext'
UPDATE [$(LIFT_Staging)].setup.DWColumns SET column_fulltype = 'varchar(max)', compare = 0 WHERE column_fulltype = 'text'
UPDATE [$(LIFT_Staging)].setup.DWColumns SET import = 0 WHERE column_fulltype = 'image'

--SELECT * FROM [$(LIFT_Staging)].setup.DWTables WHERE deleted = 1
--SELECT * FROM [$(LIFT_Staging)].setup.DWColumns WHERE deleted = 1

-- Dit zou al goed moeten staan
UPDATE [$(LIFT_Staging)].setup.DWColumns
SET import = 0
WHERE TABLE_NAME IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables WHERE import = 0) AND import = 1
-- Idem
UPDATE [$(LIFT_Staging)].setup.DWColumns
SET deleted = 1
WHERE TABLE_NAME IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables WHERE deleted = 1) AND deleted = 0

/* */

-- Tabellen zonder unid
/*
SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables WHERE import = 1
EXCEPT
SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWColumns WHERE COLUMN_NAME = 'unid'
*/
-- Momenteel hebben connectiehistorie, nummers, postponableupgrade, search_updates en version geen unid, kunnen we nu niks mee
UPDATE [$(LIFT_Staging)].setup.DWTables SET import = 0 WHERE TABLE_NAME NOT IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWColumns WHERE COLUMN_NAME = 'unid')
UPDATE [$(LIFT_Staging)].setup.DWColumns SET import = 0 WHERE TABLE_NAME NOT IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWColumns WHERE COLUMN_NAME = 'unid')

/* */

TRUNCATE TABLE [$(LIFT_Staging)].setup.RecordCount

-- Aantal rijen per tabel ophalen uit bron
DECLARE ExecuteBatches CURSOR FOR
(
SELECT
	SQLString = '
INSERT INTO
	[$(LIFT_Staging)].setup.RecordCount (TABLE_NAME, #)
SELECT
	TABLE_NAME = ''' + TABLE_NAME + '''
	, # = COUNT(*)
FROM
	' + @source_full_schema + '.' + QUOTENAME(TABLE_NAME) + ';' + char(13)
FROM
	lift.information_schema_tables
)

DECLARE @SQLString nvarchar(max)

OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @SQLString

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC (@SQLString)
	FETCH NEXT FROM ExecuteBatches INTO @SQLString
END

CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

UPDATE [$(LIFT_Staging)].setup.DWTables SET import = 0 WHERE TABLE_NAME IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.RecordCount WHERE #=0)
UPDATE [$(LIFT_Staging)].setup.DWColumns SET import = 0 WHERE TABLE_NAME IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.RecordCount WHERE #=0)

/* */

EXEC liftsetup.CreateStagingTables
EXEC liftsetup.CreateStagingIndexes -- Fout, ontbrekend unid in sysdiag? -- Werkt ook alleen nog op schema "staging", niet op staging_5_0
EXEC liftetl.LoadStagingTables -- Geeft nog fout op 'key' column (quotename erom zetten)

-- Alles opruimen:
SELECT 'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @staging_schema

-- TODO: dbo.version laten toevoegen aan replica? Of zelf checken wanneer structuur gewijzigd is...
/*
-- Tabellen zonder datwijzig:
SELECT *
FROM [$(LIFT_Staging)].setup.RecordCount
WHERE TABLE_NAME IN (
	SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables 
	EXCEPT
	SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWColumns WHERE COLUMN_NAME = 'datwijzig'
	)
ORDER BY # DESC
*/
END