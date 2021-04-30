CREATE PROCEDURE [setup].[LoadDataIntoStaging]
(
	@patDataSource varchar(64)
	, @patConnector varchar(64)
	, @debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @temp table (TABLE_NAME varchar(100), COLUMN_NAME varchar(100), DATA_TYPE varchar(35))

DECLARE ExecuteBatches CURSOR FOR
(
SELECT
	SQLString = N'
;WITH PivotData AS
(
SELECT
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' = MAX(LEN(COALESCE(JSON_VALUE(k.[value], ''$."' + c.OriginalColumnName + '"''),''1'')))'
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + '
FROM
	[Staging_Quadraam].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn, ''lax $.' + t.RowsResults + ''') k
WHERE 1=1
	AND j.DataSource = ''' + t.TABLE_SCHEMA + '''
	AND j.ContentType = ''Data''
	AND j.Connector LIKE ''' + t.Connector + '''
)

SELECT
	TABLE_NAME = ''' + t.TABLE_NAME + '''
	, COLUMN_NAME
	, DATA_TYPE = DataType
FROM
	PivotData
	UNPIVOT ([Length] FOR COLUMN_NAME IN
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + '
	)) P
	CROSS APPLY setup.TransformDataType(''string'',[Length],NULL)'
FROM
	setup.vwMetadataTables t
WHERE 1=1
	AND TABLE_SCHEMA LIKE @patDataSource
	AND TABLE_NAME LIKE @patConnector
	AND t.CREATE_SELECT = 'SELECT'
)

DECLARE @SQLString nvarchar(max)

-- Voer de gegenereerde statements uit
OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @SQLString
WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		INSERT INTO @temp
		EXEC sp_executesql @SQLString
	END TRY

	BEGIN CATCH
		PRINT ERROR_MESSAGE()
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0 COMMIT TRANSACTION

	FETCH NEXT FROM ExecuteBatches INTO @SQLString
END
CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

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
	' + STUFF((
		SELECT char(10) + char(9) + ', [' + c.COLUMN_NAME + '] = ' + CASE c.TABLE_SCHEMA
				WHEN 'Magister' THEN CASE c.DATA_TYPE
						WHEN 'bit' THEN 'CAST(NULLIF(p.value(''' + c.OriginalColumnName + '[1]'',''varchar(5)''),'''') AS ' + c.DATA_TYPE + ')'
						WHEN 'date' THEN 'p.value(''' + c.OriginalColumnName + '[1]'',''' + c.DATA_TYPE + ''')'
						ELSE 'NULLIF(p.value(''' + c.OriginalColumnName + '[1]'',''' + c.DATA_TYPE + '''),'''')'
					END
				ELSE 'LTRIM(RTRIM(w.' + c.COLUMN_NAME + '))'
			END
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + t.ExtraColumns + '
FROM
	[$(Staging_Quadraam)].setup.DataObjects j' + CASE t.TABLE_SCHEMA WHEN 'Magister' THEN '
	CROSS APPLY XMLData.nodes(''/Leerlingen/Leerling'') R(p)' ELSE '
	CROSS APPLY OPENJSON(j.BulkColumn, ''lax $.' + t.RowsResults + ''') k
	CROSS APPLY OPENJSON(k.[value]) WITH
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' ' + c.DATA_TYPE + ' ''$."' + c.OriginalColumnName + '"'''
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + '
	) w' + t.ExtraApply + '' END + '
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
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' = CAST(LTRIM(RTRIM(JSON_VALUE(k.[value], ''$."' + c.OriginalColumnName + '"''))) AS ' + y.DATA_TYPE + ')'
		FROM setup.vwMetadataColumns c
		LEFT OUTER JOIN @temp y ON c.TABLE_NAME = y.TABLE_NAME AND c.COLUMN_NAME = y.COLUMN_NAME
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
	AND j.Connector LIKE ''' + t.Connector + '''
OPTION (MAXDOP 1)' + char(10)
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

--DECLARE @SQLString nvarchar(max)
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
		PRINT ERROR_MESSAGE()
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0 COMMIT TRANSACTION

	FETCH NEXT FROM ExecuteBatches INTO @SQLString, @SortOrder
END
CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

END