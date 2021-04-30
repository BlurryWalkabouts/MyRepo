CREATE PROCEDURE [Load].[LoadDimLedger]
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

DELETE FROM Dim.Ledger

DBCC CHECKIDENT ('Dim.Ledger', RESEED, 100000000)

PRINT 'Inserting unknowns into Dim.Ledger'
SET IDENTITY_INSERT Dim.Ledger ON
INSERT INTO
	Dim.Ledger
	(
	LedgerKey
	, [Text]
	, [Description]
	)
SELECT
	LedgerKey = -1
	, [Text] = '[unknown]'
	, [Description] = '[unknown]'
SET IDENTITY_INSERT Dim.Ledger OFF

PRINT 'Inserting data into Dim.Ledger'
INSERT INTO
	Dim.Ledger
	(
	unid
	, [Text]
	, [Description]
	)
SELECT
	unid = unid
	, [Text] = tekst
	, [Description] = omschrijving
FROM
	[archive].grootboekrekening;

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