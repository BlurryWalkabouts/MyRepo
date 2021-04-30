CREATE PROCEDURE [etl].[LoadXMLFromTempStagingIntoStaging]
(
	@DatabaseLabel varchar(20)
	, @staging_schema nvarchar(max)
	, @debug bit = 0
)
AS
BEGIN

/* Nieuwe entry maken in log.Audit */

DECLARE @SourceDatabaseKey int = (SELECT Code FROM setup.SourceDefinition WHERE DatabaseLabel = @DatabaseLabel AND SourceType = 'XML')
DECLARE @SourceName nvarchar(max) = CONCAT(@DatabaseLabel, ' XML Files')
DECLARE @AuditDWKey int = 0

IF @debug = 0
	EXEC [log].LogNewAudit
		@SourceDatabaseKey = @SourceDatabaseKey
		, @SourceName = @SourceName
		, @SourceType = 'XML'
		, @TargetName = @DatabaseLabel
		, @AuditDWKey = @AuditDWKey OUTPUT
ELSE
	PRINT ''

PRINT 'SourceDatabaseKey: ' + CAST(@SourceDatabaseKey AS varchar(max)) + ', AuditDWKey: ' + CAST(@AuditDWKey AS varchar(max))

/* Data verplaatsen van tijdelijke tabellen naar echte staging-tabellen */

DECLARE T CURSOR FOR
(
SELECT TABLE_NAME
FROM setup.DWTables
WHERE import = 1
--Probleemgevallen:
--AND TABLE_NAME IN ('incident','mutatie_incident','mutatie_probleem','mutatie_change','mutatie_changeactivity','incident__memogeschiedenis','probleem__memogeschiedenis','change__memo_history','changeactivity__memo_history')
)

DECLARE @table_name nvarchar(max)

OPEN T
FETCH NEXT FROM T INTO @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'Inserting data for table: ' + @table_name

	DECLARE @columns nvarchar(max) = ''
	DECLARE @select nvarchar(max) = ''

	SELECT
		@columns += COLUMN_NAME + ', '
		, @select += COLUMN_NAME + ' = CAST(' + COLUMN_NAME + ' AS ' + DATA_TYPE +
			+ CASE WHEN DATA_TYPE LIKE '%varchar' THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'max' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS varchar(max)) END + ')' ELSE '' END
			+ CASE WHEN DATA_TYPE IN ('decimal','numeric') THEN '(' + CAST(NUMERIC_PRECISION AS varchar(max)) + ', ' + CAST(NUMERIC_PRECISION_RADIX AS varchar(max)) + ')' ELSE '' END
			+ '), '
	FROM
		[$(OGDW_Staging)].INFORMATION_SCHEMA.COLUMNS
	WHERE 1=1
		AND TABLE_NAME = @table_name
		AND TABLE_SCHEMA = 'TOPdesk'
		AND COLUMN_NAME NOT IN ('AuditDWKey','SourceDatabaseKey')

	SET @columns += 'AuditDWKey, SourceDatabaseKey'
	SET @select += 'AuditDWKey = ' + CAST(@AuditDWKey AS varchar(max)) + ', SourceDatabaseKey = ' + CAST(@SourceDatabaseKey AS varchar(max))

	-- Hier moet een filter tussen gezet worden gezet, want nu wordt iedere keer alle data toegevoegd aan onze topdesk.staging-tabellen.
	DECLARE @SQLString nvarchar(max) = '
		INSERT INTO
			[$(OGDW_Staging)].TOPdesk.' + @table_name + ' (' + @columns + ')
		SELECT
			' + @select + '
		FROM
			[$(OGDW_Staging)].[' + @staging_schema + '].' + @table_name

	BEGIN TRY
		EXEC (@SQLString)
	END TRY
	BEGIN CATCH
		PRINT 'Er gaat iets mis bij de insert: ' + ERROR_MESSAGE()
		PRINT @SQLString
		PRINT ''
	END CATCH

	FETCH NEXT FROM T INTO @table_name
END

CLOSE T
DEALLOCATE T

END