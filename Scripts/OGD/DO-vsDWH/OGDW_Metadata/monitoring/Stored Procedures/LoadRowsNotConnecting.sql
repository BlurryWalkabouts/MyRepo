CREATE PROCEDURE [monitoring].[LoadRowsNotConnecting]
(
	@db nvarchar(32)
	, @schema nvarchar(32)
)
AS 

BEGIN

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)

CREATE TABLE #CheckRecordCount
(
	TABLE_NAME sysname
	, COLUMN_NAME sysname
) 

SET @SQLString = '
INSERT INTO
	#CheckRecordCount
	(
	TABLE_NAME
	, COLUMN_NAME
	)
SELECT
	C.TABLE_NAME
	, C.COLUMN_NAME
FROM
	' + @db + '.INFORMATION_SCHEMA.COLUMNS C
	LEFT OUTER JOIN ' + @db + '.INFORMATION_SCHEMA.TABLES T ON C.TABLE_SCHEMA = T.TABLE_SCHEMA AND C.TABLE_NAME = T.TABLE_NAME
WHERE 1=1
	AND C.TABLE_SCHEMA = ''' + @schema + '''
	AND T.TABLE_TYPE = ''BASE TABLE''
	AND C.COLUMN_NAME IN (''unid'',''IncidentNumber'',''ChangeNumber'')'

EXEC (@SQLString)

DECLARE T CURSOR FOR
(
SELECT
	TABLE_NAME
	, COLUMN_NAME
FROM
	#CheckRecordCount
)

DECLARE @table nvarchar(64)
DECLARE @key nvarchar(64)

OPEN T
FETCH NEXT FROM T INTO @table, @key

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQLString = 'WITH cte AS
	(
	SELECT
		SourceDatabaseKey = ' + CASE WHEN @db = 'LIFT_Archive' THEN '0' ELSE 'SourceDatabaseKey' END + '
		, ' + @key + '
		, AuditDWKey = ' + CASE WHEN @db = 'LIFT_Archive' THEN 'LIFT' ELSE '' END + 'AuditDWKey
		, ValidFrom
		, ValidTo
	FROM
		' + @db + '.' + @schema + '.' + @table + '
	UNION
	SELECT
		SourceDatabaseKey = ' + CASE WHEN @db = 'LIFT_Archive' THEN '0' ELSE 'SourceDatabaseKey' END + '
		, ' + @key + '
		, AuditDWKey = ' + CASE WHEN @db = 'LIFT_Archive' THEN 'LIFT' ELSE '' END + 'AuditDWKey
		, ValidFrom
		, ValidTo
	FROM
		' + @db + '.history.' + @table + '
	)

	, cte2 AS
	(
	SELECT
		RowNumber = ROW_NUMBER() OVER (PARTITION BY cte.SourceDatabaseKey, ' + @key + ' ORDER BY cte.AuditDWKey)
		, ' + @key + '
		, cte.SourceDatabaseKey
		, cte.AuditDWKey
		, ValidFrom
		, ValidTo
	--	, DWDateCreated
	FROM
		cte
	--	LEFT OUTER JOIN OGDW_Metadata.[log].[Audit] a ON cte.SourceDatabaseKey = a.SourceDatabaseKey AND cte.AuditDWKey = a.AuditDWKey
	)

	INSERT INTO
		monitoring.RowsNotConnecting
		(
		DatabaseName
		, SchemaName
		, TableName
		, SourceDatabaseKey
		, PrimaryKey
		, RowNumber
		, AuditDWKey
		, ValidFrom
		, ValidTo
		, NewValidTo
		)
	SELECT
		DatabeName = ''' + @db + '''
		, SchemaName = ''' + @schema + '''
		, TableName = ''' + @table + '''
		, SourceDatabaseKey = cte2.SourceDatabaseKey
		, PrimaryKey = CAST(cte2.' + @key + ' AS nvarchar(max))
		, RowNumber = cte2.RowNumber
		, AuditDWKey = cte2.AuditDWKey
		, ValidFrom = cte2.ValidFrom
		, ValidTo = cte2.ValidTo
		, NewValidTo = COALESCE(cte3.ValidFrom,''9999-12-31 23:59:59'')
	--	, cte2.DWDateCreated
	FROM
		cte2
		LEFT OUTER JOIN cte2 cte3 ON 1=1
			AND cte2.SourceDatabaseKey = cte3.SourceDatabaseKey
			AND cte2.' + @key + ' = cte3.' + @key + '
			AND cte2.RowNumber = cte3.RowNumber - 1
	WHERE 1=1
		AND cte2.ValidTo <> cte3.ValidFrom
		OR (cte2.ValidTo <> ''9999-12-31 23:59:59'' AND cte3.ValidFrom IS NULL)
	ORDER BY
		cte2.SourceDatabaseKey
		, cte2.' + @key + '
		, cte2.AuditDWKey'

	EXEC (@SQLString)

	FETCH NEXT FROM T INTO @table, @key
END

CLOSE T
DEALLOCATE T

DROP TABLE #CheckRecordCount

END