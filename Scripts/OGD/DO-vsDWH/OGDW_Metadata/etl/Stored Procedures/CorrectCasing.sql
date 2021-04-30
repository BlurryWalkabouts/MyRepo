CREATE PROCEDURE [etl].[CorrectCasing]
(
	@schema nvarchar(50)
	, @table nvarchar(50)
	, @column nvarchar(50)
)
AS
BEGIN

/***************************************************************************************************
* [etl].[CorrectCasing]
****************************************************************************************************
* Deze procedure vervangt waarden die op verschillende posities hoofdletters bevatten.
***************************************************************************************************/

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Correcting ' + @schema + '.' + @table + '.' + @column + ' in progress...'
DECLARE @newRowCount int = 0

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max)

-- Find differences in collation and insert those values in a table variable
SET @SQLString = '
WITH cte AS
(
SELECT DISTINCT
	' + @column + '
	, ' + @column + 'Adjusted = CASE' +
			CASE WHEN EXISTS (SELECT COLUMN_NAME FROM [$(OGDW)].INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = @schema AND TABLE_NAME = @table AND COLUMN_NAME = @column + 'STD') THEN '
			WHEN ' + @column + ' = ' + @column + 'STD THEN ' + @column + 'STD'
			ELSE ''
			END + '
			WHEN ' + @column + ' COLLATE SQL_Latin1_General_CP1_CS_AS = UPPER(' + @column + ') THEN dbo.udf_TitleCase(' + @column + ')
			ELSE ' + @column + '
		END
FROM
	[$(OGDW)].' + @schema + '.' + @table + '
)
'

--Finally, update the records in the targeted table and column
SET @SQLString += '
UPDATE
	t
SET
	' + @column + ' = cte.' + @column + 'Adjusted
FROM
	[$(OGDW)].' + @schema + '.' + @table + ' t
	INNER JOIN cte ON t.' + @column + ' = cte.' + @column + ''

EXECUTE (@SQLString)

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Correcting ' + @schema + '.' + @table + '.' + @column + ' successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Correcting ' + @schema + '.' + @table + '.' + @column + ' FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END

/*
EXEC [etl].[CorrectCasing] 'Dim', 'OperatorGroup', 'OperatorGroup', 0
EXEC [etl].[CorrectCasing] 'Dim', 'OperatorGroup', 'OperatorGroup', 1
*/