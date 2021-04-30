CREATE PROCEDURE [Load].[LoadDimAccountManager]
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

DELETE FROM Dim.AccountManager

DBCC CHECKIDENT ('Dim.AccountManager', RESEED, 30000000)

PRINT 'Inserting unknowns into Dim.AccountManager'
SET IDENTITY_INSERT Dim.AccountManager ON
INSERT INTO
	Dim.AccountManager
	(
	AccountManagerKey
	, AccountManagerName
	)
SELECT
	AccountManagerKey = -1
	, AccountManagerName = '[unknown]'
SET IDENTITY_INSERT Dim.AccountManager OFF

PRINT 'Inserting data into Dim.AccountManager'
INSERT INTO
	Dim.AccountManager
	(
	unid
	, AccountManagerName
	, Archive
	, [Status]
	, CreationDate
	, ChangeDate
	)
SELECT
	am.unid
	, g.naam
	, am.archief
	, g.[status]
	, g.dataanmk
	, g.datwijzig
FROM
	[archive].accountmanager am
	LEFT OUTER JOIN [archive].gebruiker g ON am.gebruikerid = g.unid;

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