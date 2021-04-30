CREATE PROCEDURE [Load].[ArchiveLift]
(
	@debug bit = 0
)
AS
BEGIN

DECLARE @staging_schema sysname = 'Staging'
DECLARE @archive_schema sysname = 'dbo'

/********************************************************************************************
Archive new AuditDWKeys
*********************************************************************************************/

-- Empty staging table
IF @debug = 0
	TRUNCATE TABLE [Load].GenerateBatchForArchive

-- Generate batches to be executed and stored in Load.GenerateBatchForArchive
DECLARE @tableset TABLE([table_name] sysname, [sproc] nvarchar(max));

INSERT INTO @tableset
    ([table_name], [sproc])
SELECT
    [name],
    CONCAT('EXEC [Load].GenerateLiftBatch ''', @staging_schema, ''', ''', @archive_schema, ''', ''', [name], ''', ''', 'unid', ''', ', CAST(@debug AS varchar(1)), ';')
FROM (
    SELECT [name]
        FROM sys.tables
        WHERE [schema_id] = (SELECT [schema_id] FROM sys.schemas WHERE [name] = @staging_schema)
    INTERSECT
    SELECT [name]
        FROM sys.tables
        WHERE [schema_id] = (SELECT [schema_id] FROM sys.schemas WHERE [name] = @archive_schema)
    ) t;

-- Create and run batches
IF @debug = 0
BEGIN
    SET NOCOUNT OFF;
	INSERT INTO [Load].GenerateBatchForArchive
	(
		Sproc
		, SourceDatabaseKey
		, AuditDWKey
	)

	SELECT
            [sproc], NULL, NULL
        FROM @tableset
        ORDER BY [table_name];

	EXEC [Load].ExecuteBatches
END
ELSE
    SELECT
        [table_name], [sproc], NULL AS [SourceDatabaseKey], NULL AS [AuditDWKey]
    FROM @tableset;

END
