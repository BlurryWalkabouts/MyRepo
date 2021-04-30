CREATE PROCEDURE [Load].[EnableForeignKey]
(
	@ForeignKey nvarchar(128)
	, @WriteLog bit = 1
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Enabling ' + @ForeignKey + ' in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max)

SELECT TOP 1
	@SQLString = SQLStringAdd
FROM
	[Load].ForeignKeys
WHERE 1=1
	AND ForeignKey = @ForeignKey
ORDER BY
	DisableDate DESC
	
EXEC (@SQLString)

DELETE FROM
	[Load].ForeignKeys
WHERE 1=1
	AND ForeignKey = @ForeignKey

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Enabling ' + @ForeignKey + ' successful...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Enabling ' + @ForeignKey + ' FAILED...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END