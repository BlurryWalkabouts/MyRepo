CREATE PROCEDURE [shared].[EnableForeignKey]
(
	@db nvarchar(64)
	, @ForeignKey nvarchar(128)
	, @enable bit = 1
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' ' + @ForeignKey + ' in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @enable = 1
	EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max)

SELECT TOP 1
	@SQLString = SQLStringAdd
FROM
	shared.ForeignKeys
WHERE 1=1
	AND DbName = @db
	AND ForeignKey = @ForeignKey
ORDER BY
	DisableDate DESC
	
EXEC (@SQLString)

DELETE FROM
	shared.ForeignKeys
WHERE 1=1
	AND DbName = @db
	AND ForeignKey = @ForeignKey

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' ' + @ForeignKey + ' successful...'
IF @enable = 1
	EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' ' + @ForeignKey + ' FAILED...'
IF @enable = 1
	EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END

/*
EXEC shared.EnableForeignKey '[TOPdesk_DW]', 'FK_Incident_ObjectKey'
*/