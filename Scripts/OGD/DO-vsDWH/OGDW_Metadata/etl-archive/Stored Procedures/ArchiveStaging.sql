CREATE PROCEDURE [etl].[ArchiveStaging]
(
	@debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

DELETE FROM [$(OGDW_Staging)].TOPdesk.settings WHERE [type] <> 10 OR [name] NOT LIKE 'vv%'

/*******************************************************************************************
LOAD BATCHES

GenerateBatch creates executable code for every AuditDWKey for every SourceDatabaseKey
And runs over all tables. These 'batches' are stored in a staging table (myTzble) that is
then run using a cursor (execute batch)
*******************************************************************************************/

/*
The following table will be used to store strings that execute all unprocessed AuditDWKeys
for every table. The strings are stroed in the table and are then processed using a cursor

Table to store strings
etl.GenerateBatchForArchive
*/

/*
EXEC etl.ArchiveStaging 1

-- Generate statements to recreate temporal tables
DECLARE @sql varchar(max) = '
SELECT
	CONCAT(''EXEC etl.GenerateTemporalTable '', TABLE_SCHEMA, '', '', TABLE_NAME, '', '',
		CASE TABLE_NAME
			WHEN ''Changes'' THEN ''ChangeNumber''
			WHEN ''Incidents'' THEN ''IncidentNumber''
			WHEN ''settings'' THEN ''id''
			WHEN ''version'' THEN ''version''
			ELSE ''unid''
		END)
FROM
	[$(OGDW_Staging)].INFORMATION_SCHEMA.TABLES t
WHERE 1=1
	AND TABLE_TYPE = ''BASE TABLE''
	AND TABLE_SCHEMA IN (''FileImport'', ''TOPdesk'')
	AND TABLE_NAME NOT LIKE ''%backup%''
	AND TABLE_NAME NOT IN (''object_zonder_dubbele_regels'')'

PRINT @sql
*/

/********************************************************************************************
Archive new AuditDWKeys
*********************************************************************************************/
-- Empty staging table 
TRUNCATE TABLE etl.GenerateBatchForArchive

-- Generate scripts for file import batches in MyTable
EXEC etl.GenerateBatch 'FileImport', 'Incidents', 'IncidentNumber'
EXEC etl.GenerateBatch 'FileImport', 'Changes', 'ChangeNumber'

-- Generate batches to be executed and stored in etl.GenerateBatchForArchive
DECLARE @SQLString nvarchar(max) = '
	SELECT
		Sproc = ''EXEC etl.GenerateBatch '''''' + TABLE_SCHEMA + '''''', '''''' + TABLE_NAME + '''''', '''''' +
			CASE TABLE_NAME
				WHEN ''settings'' THEN ''id''
				WHEN ''version'' THEN ''version''
				ELSE ''unid''
			END + ''''''''
		, SourceDatabaseKey = NULL
		, AuditDWKey = NULL
	FROM
		[$(OGDW_Staging)].INFORMATION_SCHEMA.TABLES
	WHERE 1=1
		AND TABLE_TYPE = ''BASE TABLE''
		AND TABLE_SCHEMA = ''TOPdesk''
		AND TABLE_NAME NOT LIKE ''%backup%''
		AND TABLE_NAME NOT IN (''object_zonder_dubbele_regels'')'

-- Create batches
INSERT INTO etl.GenerateBatchForArchive
(
	Sproc
	, SourceDatabaseKey
	, AuditDWKey
)
EXEC (@SQLString)


-- Run batches
SET NOCOUNT OFF

IF @debug = 0
	EXEC etl.ExecuteBatches
ELSE
	SELECT * FROM etl.GenerateBatchForArchive
	
/***********************************************************************************************
CREATE BATCHES TO DELETE ARCHIVED BATCHES FROM STAGING
***********************************************************************************************/
TRUNCATE TABLE etl.GenerateBatchForArchive

SET @SQLString = '
	SELECT
		Sproc = ''DELETE staging
			FROM [$(OGDW_Staging)].'' + TABLE_SCHEMA + ''.'' + TABLE_NAME + '' staging
			JOIN [log].[Audit] a ON a.AuditDWKey = staging.AuditDWKey AND DWDateCreated < DATEADD(d,-2,GETDATE())
			JOIN (
				SELECT AuditDWKey = MAX(xx.AuditDWKey)
				FROM [$(OGDW_Archive)].'' + TABLE_SCHEMA + ''.'' + TABLE_NAME + '' xx
				GROUP BY xx.AuditDWKey
				) archive ON staging.AuditDWKey <= archive.AuditDWKey''
		, SourceDatabaseKey = NULL
		, AuditDWKey = NULL
	FROM
		[$(OGDW_Staging)].INFORMATION_SCHEMA.TABLES
	WHERE 1=1
		AND TABLE_TYPE = ''BASE TABLE''
		AND ((TABLE_SCHEMA = ''FileImport'' AND TABLE_NAME IN (''Changes'', ''Incidents''))
		 OR (TABLE_SCHEMA = ''TOPdesk'' AND TABLE_NAME IN (''incident'')))'

-- Store delete statements in table
INSERT INTO etl.GenerateBatchForArchive
(
	Sproc
	, SourceDatabaseKey
	, AuditDWKey
)
EXEC (@SQLString)

-- Run batches
SET NOCOUNT OFF

IF @debug = 0
	EXEC etl.ExecuteBatches
ELSE
	SELECT * FROM etl.GenerateBatchForArchive

END