CREATE PROCEDURE [Load].[GenerateLiftBatch]
(
	@staging_schema sysname
	, @archive_schema sysname
	, @table sysname
	, @pkfield1 varchar(max)  = 'unid'
	, @debug bit = 0
)
AS
BEGIN

DECLARE @SQLString nvarchar(max) = '
SELECT
	Sproc = CONCAT(''EXEC [Load].LoadLiftTemporalTable '', ''''''' + @staging_schema + ''''', '', ''''''' + @archive_schema + ''''', '', ''''''' + @table + ''''', '', ''''''' + @pkfield1 + ''''', '', a.AuditDWKey,'';'')
	, SourceDatabaseKey = NULL
	, AuditDWKey = a.AuditDWKey
FROM
	[log].[Audit] a
	JOIN ' + @staging_schema + '.' + @table + ' x ON x.AuditDWKey = a.AuditDWKey
WHERE 1=1
	AND a.AuditDWKey > (SELECT ISNULL(MAX(AuditDWKey),0) FROM ' + @archive_schema + '.' + @table + ' a)
GROUP BY
	a.AuditDWKey
ORDER BY
	a.AuditDWKey'

IF @debug = 0
	INSERT INTO [Load].GenerateBatchForArchive 
	(
		Sproc
		, SourceDatabaseKey
		, AuditDWKey
	)
	EXEC (@SQLString) 
ELSE
	PRINT @SQLString

END