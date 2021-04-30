CREATE PROCEDURE [etl].[LoadDimReportInfo]
AS
BEGIN

-- ================================================
-- Create dim table for Report Info.
-- This is a straight copy from MDS.
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

DELETE FROM [$(OGDW)].Dim.ReportInfo

INSERT INTO
	[$(OGDW)].Dim.ReportInfo
	(
	[Name]
	, Code
	, ReportName
	, LandingPage
	, PDF
	, Word
	, Logo
	, EnableIncidents
	, EnableChanges
	, EnableCalls
	)
SELECT
	[Name]
	, Code
	, ReportName
	, LandingPage
	, PDF
	, Word
	, Logo
	, EnableIncidents
	, EnableChanges
	, EnableCalls
FROM
	[$(MDS)].mdm.ReportInfo

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