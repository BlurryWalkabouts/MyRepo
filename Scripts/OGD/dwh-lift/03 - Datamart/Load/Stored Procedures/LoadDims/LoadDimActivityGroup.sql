CREATE PROCEDURE [Load].[LoadDimActivityGroup]
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

DELETE FROM Dim.ActivityGroup

DBCC CHECKIDENT ('Dim.ActivityGroup', RESEED, 15000000)

PRINT 'Inserting unknowns into Dim.ActivityGroup'
SET IDENTITY_INSERT Dim.ActivityGroup ON
INSERT INTO
	Dim.ActivityGroup
	(
	ActivityGroupKey	     				
	, ActivityGroupName
	, ActivityGroupStatus
	)
SELECT
	ActivityGroupKey = -1		
	, ActivityGroupName = '[unknown]'
	, ActivityGroupStatus = -1	
SET IDENTITY_INSERT Dim.ActivityGroup OFF

PRINT 'Inserting data into Dim.ActivityGroup'
INSERT INTO
	Dim.ActivityGroup
	(
          unid
	, ActivityGroupName
	, ActivityGroupStatus	
	)
SELECT	
	 unid	= ag.unid
	, ActivityGroupName = ag.naam
	, ActivityGroupStatus = ag.[status]
FROM
	[archive].activiteitgroep ag;
	
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