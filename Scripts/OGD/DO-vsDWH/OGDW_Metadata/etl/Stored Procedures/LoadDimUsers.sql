CREATE PROCEDURE [etl].[LoadDimUsers]
AS
BEGIN

-- ================================================
-- Create dim table for Users.
-- This is a copy from MDS with optimized load time.
-- ================================================

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

-- Verwijder records die niet meer bestaan in MDS
DELETE FROM
	[$(OGDW)].Dim.Users
WHERE 1=1
	AND Code NOT IN (SELECT Code FROM [$(MDS)].mdm.Users)

-- Nieuwe records toevoegen:
INSERT INTO
	[$(OGDW)].Dim.Users
	(
	Code
	, [Name]
	, SecurityClearance
	, LastChgDateTime
	)
SELECT
	Code
	, [Name]
	, SecurityClearance_Name 
	, LastChgDateTime
FROM
	[$(MDS)].mdm.Users
WHERE 1=1
	AND Code NOT IN (SELECT Code FROM [$(OGDW)].Dim.Users)

SET @newRowCount += @@ROWCOUNT

-- Gewijzigde records aanpassen:
UPDATE
	[$(OGDW)].Dim.Users
SET
	Code = S.Code
	, [Name] = S.[Name]
	, SecurityClearance = S.SecurityClearance_Name
	, LastChgDateTime = S.LastChgDateTime
FROM
	[$(MDS)].mdm.Users S -- Source
	INNER JOIN [$(OGDW)].Dim.Users T -- Target 
		ON S.Code = T.Code AND S.LastChgDateTime > T.LastChgDateTime -- Alleen nieuwere records aanpassen

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