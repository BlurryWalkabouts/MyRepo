CREATE PROCEDURE [Load].[LoadDimTask]
(
	@WriteLog bit = 1
)
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
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM Dim.Task

DBCC CHECKIDENT ('Dim.Task', RESEED, 120000000)

PRINT 'Inserting unknowns into Dim.Task'
SET IDENTITY_INSERT Dim.Task ON
INSERT INTO
	Dim.Task
	(
	TaskKey
	, TaskNumber
	, TaskName
	)
SELECT
	TaskKey = -1
	, TaskNumber = '[unknown]'
	, TaskName = '[unknown]'
SET IDENTITY_INSERT Dim.Task OFF

PRINT 'Inserting data into Dim.Task'
INSERT INTO
	Dim.Task
	(
	unid
	, TaskNumber
	, TaskName
	, TaskStatus
	, IsPublic
	, TaskEndDate
	)
SELECT
	unid = unid
	, TaskNumber = taaknr
	, TaskName = taaknaam
	, TaskStatus = [status]
	, IsPublic = iedereen
	, TaskEndDate = einddatum
FROM
	[archive].taak

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END