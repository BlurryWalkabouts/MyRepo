CREATE PROCEDURE [Load].[LoadDimService]
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

DELETE FROM Dim.[Service]

DBCC CHECKIDENT ('Dim.Service', RESEED, 60000000)

PRINT 'Inserting unknowns into Dim.Service'
SET IDENTITY_INSERT Dim.[Service] ON
INSERT INTO
	Dim.[Service]
	(
	ServiceKey
	, ProductNomination
	)
SELECT
	ServiceKey = -1
	, ProductNomination = '[unknown]'
SET IDENTITY_INSERT Dim.[Service] OFF

PRINT 'Inserting data into Dim.Service'
INSERT INTO
	Dim.[Service]
	(
	ProductNomination
	)
SELECT DISTINCT
	ProductNomination = naam
FROM
	[archive].dienst

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