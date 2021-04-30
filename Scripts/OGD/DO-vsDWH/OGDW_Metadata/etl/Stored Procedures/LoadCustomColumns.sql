CREATE PROCEDURE [etl].[LoadCustomColumns]
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

TRUNCATE TABLE etl.CustomColumns

INSERT INTO
	etl.CustomColumns
	(
	TABLE_NAME
	, COLUMN_NAME
	, ColumnDefinition
	, SourceDatabaseKey
	, AuditDWKey
	)
SELECT
	TABLE_NAME = SUBSTRING([name], 4, CHARINDEX('.', [name]) - 4)
	, COLUMN_NAME = SUBSTRING([name], CHARINDEX('.', [name]) + 1, CHARINDEX('naam1', [name]) - CHARINDEX('.', [name]) - 1)
	, ColumnDefinition = characters
	, SourceDatabaseKey
	, AuditDWKey
FROM
	[$(OGDW_Archive)].TOPdesk.settings
WHERE 1=1
	AND [type] = 10
	AND [name] LIKE 'vv%1'
	AND [name] NOT LIKE 'vv%vrijeopzoek%1'
	AND [name] NOT LIKE 'vv%tabnamenaam1'
	AND [name] NOT LIKE 'vv%.naam1'
	AND [name] NOT LIKE '%groep%'
	AND characters <> ''

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END