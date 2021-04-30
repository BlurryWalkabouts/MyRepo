CREATE PROCEDURE [Load].[LoadDimDiploma]
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

DELETE FROM Dim.Diploma

DBCC CHECKIDENT ('Dim.Diploma', RESEED, 90000000)

PRINT 'Inserting unknowns into Dim.Diploma'
SET IDENTITY_INSERT Dim.Diploma ON
INSERT INTO
	Dim.Diploma
	(
	DiplomaKey
	, Diploma
	)
SELECT
	DiplomaKey = -1
	, Diploma = '[unknown]'
SET IDENTITY_INSERT Dim.Diploma OFF

PRINT 'Inserting data into Dim.Diploma'
INSERT INTO
	Dim.Diploma
	(
	unid
	, Diploma
	)
SELECT
	unid = d.unid
	, Diploma = d.tekst
FROM
    [archive].diploma d;

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