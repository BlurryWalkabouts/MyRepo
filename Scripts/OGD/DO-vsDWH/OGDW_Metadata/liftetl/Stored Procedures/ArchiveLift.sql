CREATE PROCEDURE [liftetl].[ArchiveLift]
(
	@debug bit = 0
)
AS
BEGIN

DECLARE @staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))
DECLARE @archive_schema sysname = 'dbo'

/********************************************************************************************
Archive new LiftAuditDWKeys
*********************************************************************************************/

-- Empty staging table
IF @debug = 0
	TRUNCATE TABLE etl.GenerateBatchForArchive

-- Generate batches to be executed and stored in etl.GenerateBatchForArchive
DECLARE @SQLString varchar(max) = '
SELECT
	Sproc = ''EXEC liftetl.GenerateLiftBatch '''''' + TABLE_SCHEMA + '''''', ''''' + @archive_schema + ''''', '''''' + TABLE_NAME + '''''', '''''' + ''unid'' + '''''', ' + CAST(@debug AS varchar(1)) + '''
	, SourceDatabaseKey = NULL
	, AuditDWKey = NULL
FROM
	[$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES t
WHERE 1=1
	AND TABLE_SCHEMA = ''' + @staging_schema + '''
	AND TABLE_TYPE = ''BASE TABLE''' +
/* Currently five tables (connectiehistorie, nummers, postponableupgrade, search_updates, version) don't use unid, so these need to be handled differently.
They are not imported anyway, so for now they have simply been excluded. */ + '
	AND TABLE_NAME NOT IN (
		SELECT TABLE_NAME
		FROM [$(LIFT_Staging)].setup.DWColumns d
		WHERE d.TABLE_NAME NOT IN (SELECT dd.TABLE_NAME FROM [$(LIFT_Staging)].setup.DWColumns dd WHERE dd.COLUMN_NAME = ''unid'')
		GROUP BY TABLE_NAME
		)
ORDER BY
	TABLE_NAME'

-- Create batches
IF @debug = 0
BEGIN
	INSERT INTO etl.GenerateBatchForArchive
	(
		Sproc
		, SourceDatabaseKey
		, AuditDWKey
	)
	EXEC (@SQLString)
END
ELSE
	PRINT @SQLString

-- Run batches
SET NOCOUNT OFF

IF @debug = 0
	EXEC etl.ExecuteBatches
ELSE
	EXEC (@SQLString)

END