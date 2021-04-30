CREATE PROCEDURE [etl].[LoadDimCaller]
AS
BEGIN

-- ================================================
-- Create dim table for Caller.
--
-- Join from Incidents table on SourceDatabaseKey and CallerID
-- Join from Changes table on SourceDatabaseKey and CallerName (or if that is null, use CallerEmail)
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

-- Clear the dim so we can rebuild it
DELETE FROM [$(OGDW)].Dim.[Caller]
DBCC CHECKIDENT ('[$(OGDW)].Dim.[Caller]', RESEED, 0)

-- Insert default line
SET IDENTITY_INSERT [$(OGDW)].Dim.[Caller] ON
INSERT INTO
	[$(OGDW)].Dim.[Caller] (CallerKey, SourceDatabaseKey, CallerName)
VALUES
	(-1, -1, '[Onbekend]')
SET @newRowCount += @@ROWCOUNT
SET IDENTITY_INSERT [$(OGDW)].Dim.[Caller] OFF

-- Add to dimension table with generated key
INSERT INTO
	[$(OGDW)].Dim.[Caller]
	(
	SourceDatabaseKey
--	, CallerID
	, CallerName
	, CallerEmail
	, CallerTelephoneNumber
	, CallerTelephoneNumberSTD
	, CallerMobileNumber
	, CallerMobileNumberSTD
	, Department
	, CallerBranch
	, CallerCity
	, CallerLocation
	, CallerRegion
	, CallerGender
	)
SELECT
	CA.SourceDatabaseKey
--	, CA.CallerID
	, CA.CallerName
	, CA.CallerEmail
	, CA.CallerTelephoneNumber
	, CA.CallerTelephoneNumberSTD
	, CA.CallerMobileNumber
	, CA.CallerMobileNumberSTD
	, CA.CallerDepartment
	, CA.CallerBranch
	, CA.CallerCity
	, CA.CallerLocation
	, CA.CallerRegion
	, CA.CallerGender
FROM
	etl.Translated_Caller CA

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