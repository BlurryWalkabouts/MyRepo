CREATE PROCEDURE [etl].[ReplaceEmptyString]
(
	@schema nvarchar(50)
	, @table nvarchar(50)
	, @column nvarchar(50)
	, @newValue nvarchar(50)
	, @debug bit = 0
)
AS
BEGIN

/***************************************************************************************************
* [etl].[ReplaceEmptyString]
****************************************************************************************************
* Deze procedure vervangt in de opgegeven kolom alle lege strings en NULL waarden door '[Geen]'
****************************************************************************************************
* 2017-01-03 * WvdS	* Eerste versie
***************************************************************************************************/

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Replacing ' + @schema + '.' + @table + '.' + @column + ' in progress...'
DECLARE @newRowCount int = 0

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max)= ''

-- Bouw de update string op
SET @SQLString = N'
	UPDATE [$(OGDW)].' + @schema + '.' + @table + ' 
	SET ' + @column + ' = ''[' + @newValue + ']''
	FROM [$(OGDW)].' + @schema + '.' + @table +'
	WHERE 1<>1
		OR ' + @column + ' = ''''
		OR ' + @column + ' IS NULL'

EXECUTE (@SQLString)

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Replacing ' + @schema + '.' + @table + '.' + @column + ' successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Replacing ' + @schema + '.' + @table + '.' + @column + ' FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END

/*
EXEC [etl].[ReplaceEmptyString] 'Dim','OperatorGroup','OperatorGroup',1
*/