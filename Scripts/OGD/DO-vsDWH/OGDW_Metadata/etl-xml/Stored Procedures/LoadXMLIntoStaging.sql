CREATE PROCEDURE [etl].[LoadXMLIntoStaging]
(
	@DatabaseLabel varchar(20)
)
AS
BEGIN

/* Tijdelijk schema aanmaken, we maken voor iedere dag een nieuwe schema */

DECLARE @SQLString nvarchar(max) 
DECLARE @dir varchar(100) = '$(ETL_Path)\$(DB_Exports)\' + @DatabaseLabel + '\'
DECLARE @staging_schema nvarchar(max) = @DatabaseLabel + '_TOPdesk_' + CONVERT(varchar(8), GETDATE(), 112)

SET @SQLString = N'CREATE SCHEMA [' + @staging_schema + ']'

BEGIN TRY
	EXEC [$(OGDW_Staging)].dbo.sp_executesql @SQLString
END TRY
BEGIN CATCH
	PRINT 'Schema [' + @staging_schema + '] aanmaken mislukt.'
END CATCH

/* Data laden in tijdelijke tabellen */

DECLARE T CURSOR FOR
(
SELECT TABLE_NAME
FROM setup.DWTables
WHERE import = 1
)

DECLARE @table_name nvarchar(max) = ''

OPEN T
FETCH NEXT FROM T INTO @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
--	PRINT @table_name
	SET @SQLString = '
		SELECT
			*
		INTO
			[$(OGDW_Staging)].[' + @staging_schema + '].' + @table_name + '
		FROM
			OPENROWSET(BULK ''' + @dir + @table_name + '.dat'',
			FORMATFILE=''' + @dir + @table_name + '.format.xml'') t'
--	PRINT @SQLString
	EXEC (@SQLString)
	FETCH NEXT FROM T INTO @table_name
END

CLOSE T
DEALLOCATE T

/* Data verplaatsen naar echte staging-tabellen */

BEGIN TRY
	EXEC etl.LoadXMLFromTempStagingIntoStaging @DatabaseLabel, @staging_schema
END TRY
BEGIN CATCH
	PRINT 'Laden mislukt ' + ERROR_MESSAGE()
	-- Todo: deels ingelezen data opruimen
	RAISERROR ('etl.LoadXMLFromTempStagingIntoStaging failed', -- Message text.
            16, -- Severity.
            1-- State.
            )
END CATCH

/* Tijdelijk schema en tabellen weer opruimen */

EXEC etl.RemoveStagingSchemaAndTables @staging_schema
 
END

/*
SELECT * FROM OGDW_Metadata.[log].[Audit] ORDER BY AuditDWKey DESC
EXEC etl.LoadXMLIntoStaging @DatabaseLabel = 'GVBLokaal'
EXEC etl.LoadXMLIntoStaging @DatabaseLabel = 'Beweging3_SFTP'
DROP SCHEMA Gvblokaal_TOPdesk_20160608
*/