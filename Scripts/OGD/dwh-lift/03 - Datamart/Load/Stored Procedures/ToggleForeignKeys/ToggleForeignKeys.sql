CREATE PROCEDURE [Load].[ToggleForeignKeys]
(
	@enable bit
	, @WriteLog bit
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' foreign keys in progress...'
DECLARE @newRowCount int

-- Start logging
EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

--BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max) = ''

SET @SQLString += '
DECLARE ExecuteBatches CURSOR FOR
(' + CASE WHEN @enable = 0 THEN '
SELECT
	ForeignKey = [name]
FROM
	sys.foreign_keys' ELSE '
SELECT DISTINCT
	ForeignKey
FROM
	[Load].ForeignKeys' END + '
)

DECLARE @ForeignKey nvarchar(128)
'
-- Voer de gegenereerde statements uit
SET @SQLString += '
OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @ForeignKey
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC [Load].' + CASE WHEN @enable = 0 THEN 'Disable' ELSE 'Enable' END + 'ForeignKey @ForeignKey = @ForeignKey, @WriteLog = ' + CAST(@WriteLog AS varchar(1)) + '
	FETCH NEXT FROM ExecuteBatches INTO @ForeignKey
END
CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches'

EXEC (@SQLString)

SET @newRowCount = @@ROWCOUNT
--COMMIT TRANSACTION

-- Logging of success
SET @newMessage = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' foreign keys completed...'
EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
--ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' foreign keys FAILED...'
EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END