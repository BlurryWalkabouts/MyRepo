CREATE PROCEDURE [liftvalidate].[CheckRecordCount]
AS
BEGIN

/*
Geeft tabel met aantallen, aantallen Current en Non-Current en aantallen in de bijbehorende staging-view.
CurrentCount moet overeenkomen met StagingVWCount
*/

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)
DECLARE @staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))
DECLARE @source_full_schema sysname = '[$(LIFTServer)].[$(LIFT5)].dbo'

DROP TABLE IF EXISTS #CheckRecordCount
	
CREATE TABLE #CheckRecordCount
(
	TABLE_NAME sysname
	, LIFT5_Live_Count int
	, NonCurrentCount int
	, CurrentCount int
	,  StagingCount int
) 

INSERT INTO
	#CheckRecordCount (TABLE_NAME)
SELECT
	TABLE_NAME
FROM
	[$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES
WHERE 1=1
	AND TABLE_SCHEMA = @staging_schema
	AND TABLE_TYPE = 'BASE TABLE'

DECLARE c CURSOR FOR
(
SELECT TABLE_NAME
FROM #CheckRecordCount
)

DECLARE @table_name sysname

OPEN c
FETCH NEXT FROM c INTO @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQLString = 'UPDATE #CheckRecordCount
	SET LIFT5_Live_Count = (SELECT COUNT(*) FROM ' + @source_full_schema + '.' + @table_name + ')
	WHERE table_name = ''' + @table_name + ''''
	EXEC (@SQLString)
/*
	SET @SQLString = 'UPDATE #CheckRecordCount
	SET NonCurrentCount = (SELECT COUNT(*) FROM dbo.' + @table_name + ' WHERE DWCurrent = 0)
	WHERE TABLE_NAME = ''' + @table_name + ''''
	EXEC (@SQLString)

	SET @SQLString = 'UPDATE #CheckRecordCount
	SET CurrentCount = (SELECT COUNT(*) FROM dbo.' + @table_name + ' WHERE DWCurrent = 1)
	WHERE TABLE_NAME = ''' + @table_name + ''''
	EXEC (@SQLString)
*/		
	SET @SQLString = 'UPDATE #CheckRecordCount
	SET StagingCount = (SELECT COUNT(*) FROM [$(LIFT_Staging)].' + @staging_schema + '.' + @table_name + ')
	WHERE TABLE_NAME = ''' + @table_name + ''''
	EXEC (@SQLString)

	FETCH NEXT FROM c INTO @table_name
END

CLOSE c
DEALLOCATE c

SELECT * FROM #CheckRecordCount
SELECT * FROM #CheckRecordCount WHERE CurrentCount <> StagingCount

END

/*
SELECT * FROM ##CheckRecordCount WHERE CurrentCount <> StagingVWCount
*/