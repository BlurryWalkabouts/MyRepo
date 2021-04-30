CREATE PROCEDURE [Load].[LoadDimHourType]
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

DELETE FROM Dim.HourType

DBCC CHECKIDENT ('Dim.HourType', RESEED, 50000000)

PRINT 'Inserting unknowns into Dim.HourType'
SET IDENTITY_INSERT Dim.HourType ON
INSERT INTO
	Dim.HourType
	(
	HourTypeKey
	, [Percentage]
	, Billable
	, RateName
	)
SELECT
	HourTypeKey = -1
	, [Percentage] = NULL
	, Billable = NULL
	, RateName = '[unknown]'
SET IDENTITY_INSERT Dim.HourType OFF

PRINT 'Inserting data into Dim.HourType'
INSERT INTO
	Dim.HourType
	(
	[Percentage]
	, Billable
	, RateName
	)
SELECT DISTINCT
	[Percentage] = procent
	, Billable = declarabel
	, RateName = tariefnaam
FROM
    [archive].uurtype;

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