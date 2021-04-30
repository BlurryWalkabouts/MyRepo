CREATE PROCEDURE [liftetl].[GenerateLiftBatch]
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
	Sproc = CONCAT(''EXEC liftetl.LoadLiftTemporalTable '', ''''''' + @staging_schema + ''''', '', ''''''' + @archive_schema + ''''', '', ''''''' + @table + ''''', '', ''''''' + @pkfield1 + ''''', '', a.LiftAuditDWKey,'';'')
	, SourceDatabaseKey = NULL
	, AuditDWKey = a.LiftAuditDWKey
FROM
	[log].LiftAudit a
	JOIN [$(LIFT_Staging)].' + @staging_schema + '.' + @table + ' x ON x.AuditDWKey = a.LiftAuditDWKey
WHERE 1=1
	AND a.LiftAuditDWKey > (SELECT ISNULL(MAX(AuditDWKey),0) FROM [$(LIFT_Archive)].' + @archive_schema + '.' + @table + ' a)
GROUP BY
	a.LiftAuditDWKey
ORDER BY
	a.LiftAuditDWKey'

IF @debug = 0
	INSERT INTO etl.GenerateBatchForArchive 
	(
		Sproc
		, SourceDatabaseKey
		, AuditDWKey
	)
	EXEC (@SQLString) 
ELSE
	PRINT @SQLString

END