CREATE PROCEDURE [monitoring].[CompareArchiveToStaging]
(
	@db nvarchar(64)
	, @schema nvarchar(64)
	, @showresult bit = 1
)
AS
/*
Geeft tabel met aantallen, aantallen Current en Non-Current en aantallen in de bijbehorende staging-view.
CurrentCount moet overeenkomen met StagingVWCount
*/

BEGIN

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)
DECLARE @table_name sysname

DROP TABLE IF EXISTS ##CheckRecordCount

CREATE TABLE ##CheckRecordCount
(
	table_name sysname
	, StagingCount int
	, CurrentCount int
	, HistoryCount int
) 

SET @SQLString = '
INSERT INTO
	##CheckRecordCount(table_name)
SELECT
	table_name
FROM
	' + @db + '.INFORMATION_SCHEMA.TABLES
WHERE 1=1
	AND TABLE_SCHEMA = ''' + @schema + '''
	AND TABLE_TYPE = ''BASE TABLE''
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM ' + @db + '.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = ''unid'')'

EXEC (@SQLString)

DECLARE T CURSOR FOR
(
SELECT table_name FROM ##CheckRecordCount
)

OPEN T
FETCH NEXT FROM T INTO @table_name
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Fill StagingCount monitoring.[CheckArchiveCount]
	SET @SQLString = '
	UPDATE
		##CheckRecordCount 
	SET
		StagingCount = (SELECT COUNT(DISTINCT unid) FROM ' + @db + '.' + @schema + '.' + @table_name + ')
	WHERE 1=1
		AND table_name = ''' + @table_name + ''''
	EXEC (@SQLString)

	-- Fill CurrentCount (voor staging moet schema naam van lift vervangen worden met dbo)
	SET @SQLString = '
	UPDATE
		##CheckRecordCount
	SET
		CurrentCount = (SELECT COUNT(DISTINCT unid) FROM ' + REPLACE(@db,'Staging','Archive') + '.' + CASE @db WHEN '[$(LIFT_Staging)]' THEN 'dbo' ELSE @schema END + '.' + @table_name + ')
	WHERE 1=1
		AND table_name = ''' + @table_name + ''''
	EXEC (@SQLString)

	-- Fill HistoryCount
	SET @SQLString = '
	UPDATE
		##CheckRecordCount
	SET
		HistoryCount = (SELECT COUNT(DISTINCT unid) FROM ' + REPLACE(@db,'Staging','Archive') + '.History.' + @table_name + ')
	WHERE 1=1
		AND table_name = ''' + @table_name + ''''
	EXEC (@SQLString)
	FETCH NEXT FROM T INTO @table_name
END
CLOSE T
DEALLOCATE T

IF @showresult = 1
	SELECT * FROM ##CheckRecordCount WHERE ISNULL(StagingCount,0) <> ISNULL(CurrentCount,0) ORDER BY table_name

END