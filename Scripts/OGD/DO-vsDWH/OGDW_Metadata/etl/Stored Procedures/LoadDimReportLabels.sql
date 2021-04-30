CREATE PROCEDURE [etl].[LoadDimReportLabels]
AS
BEGIN

-- ================================================
-- Create dim table for Report Labels.
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

DELETE FROM [$(OGDW)].Dim.ReportLabels

INSERT INTO
	[$(OGDW)].Dim.ReportLabels
	(
	LanguageCode
	, [Language]
	, Locale
	, [Name]
	, Code
	, Translation
	)
SELECT
	LanguageCode = L.Code
	, L.[Language]
	, L.Locale
	, R.[Name]
	, Code = COALESCE(RL.Code, R.Code)
	, Translation = COALESCE(RL.Translation, R.Translation)
FROM [$(MDS)].mdm.Languages L
	INNER JOIN [$(MDS)].mdm.ReportLabels R ON R.Language_Code = COALESCE(L.MainLanguage_Code, L.Code)
	LEFT JOIN [$(MDS)].mdm.ReportLabels RL ON RL.Language_Code = L.Code AND R.[Name] = RL.[Name]

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