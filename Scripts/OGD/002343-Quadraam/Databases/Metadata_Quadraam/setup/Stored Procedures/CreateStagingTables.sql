CREATE PROCEDURE [setup].[CreateStagingTables]
(
	@patDataSource varchar(64)
	, @patConnector varchar(64)
	, @debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

DECLARE ExecuteBatches CURSOR FOR
(
-- Genereer een statement dat er voor zorgt dat het schema bestaat
SELECT
	SQLString = '[$(Staging_Quadraam)]..sp_executesql N''IF SCHEMA_ID(''''' + TABLE_SCHEMA + ''''') IS NULL EXEC(''''CREATE SCHEMA [' + TABLE_SCHEMA + '] AUTHORIZATION dbo;'''')'''
	, SortOrder = 0
FROM
	setup.vwMetadataTables
WHERE 1=1
	AND TABLE_SCHEMA LIKE @patDataSource
	AND TABLE_NAME LIKE @patConnector

UNION

-- Genereer de DROP statements voor iedere tabel die aan het patroon voldoet
SELECT
	SQLString = 'DROP TABLE IF EXISTS ' + TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME
	, SortOrder = 1
FROM
	[$(Staging_Quadraam)].INFORMATION_SCHEMA.TABLES
WHERE 1=1
	AND TABLE_SCHEMA LIKE @patDataSource
	AND TABLE_NAME LIKE @patConnector
	AND TABLE_SCHEMA <> 'setup'

UNION

-- Genereer de CREATE statements voor iedere tabel die aan het patroon voldoet
SELECT
	SQLString = '
CREATE TABLE
	[$(Staging_Quadraam)].' + t.TABLE_SCHEMA + '.' + t.TABLE_NAME + '
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' ' + c.DATA_TYPE + ' NULL'
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + t.ExtraColumnDefinitions + '
	)
	
INSERT INTO
	[$(Staging_Quadraam)].' + t.TABLE_SCHEMA + '.' + t.TABLE_NAME + '
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + t.ExtraColumns + '
	)
SELECT
	w.*' + t.ExtraColumns + '
FROM
	[$(Staging_Quadraam)].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn, ''lax $.' + t.RowsResults + ''') k
	CROSS APPLY OPENJSON(k.[value]) WITH
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' ' + c.DATA_TYPE + ' ''$."' + c.OriginalColumnName + '"'''
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + '
	) w' + t.ExtraApply + '
WHERE 1=1
	AND j.DataSource = ''' + t.TABLE_SCHEMA + '''
	AND j.ContentType = ''Data''
	AND j.Connector LIKE ''' + t.Connector + '''' + char(10)
	, SortOrder = 2
FROM
	setup.vwMetadataTables t
WHERE 1=1
	AND t.TABLE_SCHEMA LIKE @patDataSource
	AND t.TABLE_NAME LIKE @patConnector
	AND t.CREATE_SELECT = 'CREATE'

UNION

-- Genereer de SELECT INTO statements voor iedere tabel die aan het patroon voldoet
SELECT
	SQLString = '
SELECT
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' = JSON_VALUE(k.[value], ''$."' + c.OriginalColumnName + '"'')'
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + t.ExtraColumns + '
INTO
	[$(Staging_Quadraam)].' + t.TABLE_SCHEMA + '.' + t.TABLE_NAME + '
FROM
	[$(Staging_Quadraam)].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn, ''lax $.' + t.RowsResults + ''') k' + t.ExtraApply + '
WHERE 1=1
	AND j.DataSource = ''' + t.TABLE_SCHEMA + '''
	AND j.ContentType = ''Data''
	AND j.Connector LIKE ''' + t.Connector + '''' + char(10)
	, SortOrder = 3
FROM
	setup.vwMetadataTables t
WHERE 1=1
	AND t.TABLE_SCHEMA LIKE @patDataSource
	AND t.TABLE_NAME LIKE @patConnector
	AND t.CREATE_SELECT = 'SELECT'
)
ORDER BY
	SortOrder

DECLARE @SQLString nvarchar(max)
DECLARE @SortOrder tinyint

-- Voer de gegenereerde statements uit
OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @SQLString, @SortOrder
WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		IF @debug = 0
			EXEC (@SQLString)
		ELSE
			PRINT @SQLString
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0 COMMIT TRANSACTION

	FETCH NEXT FROM ExecuteBatches INTO @SQLString, @SortOrder
END
CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

END