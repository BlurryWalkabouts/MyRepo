CREATE PROCEDURE [etl].[LoadDimSLA]
AS
BEGIN

-- ================================================
-- Create dim table for SLA.
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
	[$(OGDW)].Dim.SLA
WHERE 1=1
	AND Code NOT IN (SELECT Code FROM [$(MDS)].mdm.DimSLA)

-- Nieuwe records toevoegen:
INSERT INTO
	[$(OGDW)].Dim.SLA
	(
	Code
	, [Name]
	, CallResponseTimeValue
	, CallResponseTimeRate
	, CallDurationValue
	, CallDurationRate
	, MailResponseTimeValue
	, MailResponseTimeRate
	, IncidentFirstlineResolveRate
	, IncidentVerstoringResolveRate
	, IncidentFirstlineDuration
	, IncidentSecondlineDuration
	, StandardChangeDurationRate
	, IncidentVerstoringP1ResolveRate
	, IncidentVerstoringP2ResolveRate
	, IncidentVerstoringP3ResolveRate
	, IncidentAanvraagP5ResolveRate
	, IncidentVraagP5ResolveRate
	, KlachtResolveRate
	, ProblemResolveRate
	, ChangeAuthTimeValue
	, ChangeAuthTimeRate
	, ChangeClosingTimeValue
	, ChangeClosingTimeRate
	, LastChgDateTime
	)
SELECT 
	Code
	, [Name]
	, CallResponseTimeValue
	, CallResponseTimeRate
	, CallDurationValue
	, CallDurationRate
	, MailResponseTimeValue
	, MailResponseTimeRate
	, IncidentFirstlineResolveRate
	, IncidentVerstoringResolveRate
	, IncidentFirstlineDuration
	, IncidentSecondlineDuration
	, StandardChangeDurationRate
	, IncidentVerstoringP1ResolveRate
	, IncidentVerstoringP2ResolveRate
	, IncidentVerstoringP3ResolveRate
	, IncidentAanvraagP5ResolveRate
	, IncidentVraagP5ResolveRate
	, KlachtResolveRate
	, ProblemResolveRate
	, ChangeAuthTimeValue
	, ChangeAuthTimeRate
	, ChangeClosingTimeValue
	, ChangeClosingTimeRate
	, LastChgDateTime
FROM
	[$(MDS)].mdm.DimSLA
WHERE 1=1
	AND Code NOT IN (SELECT DISTINCT Code FROM [$(OGDW)].Dim.SLA)

SET @newRowCount += @@ROWCOUNT

-- Gewijzigde records aanpassen:
UPDATE
	[$(OGDW)].Dim.SLA
SET
	Code = S.Code
	, [Name] = S.[Name]
	, CallResponseTimeValue = S.CallResponseTimeValue
	, CallResponseTimeRate = S.CallResponseTimeRate
	, CallDurationValue = S.CallDurationValue
	, CallDurationRate = S.CallDurationRate
	, MailResponseTimeValue = S.MailResponseTimeValue
	, MailResponseTimeRate = S.MailResponseTimeRate
	, IncidentFirstlineResolveRate = S.IncidentFirstlineResolveRate
	, IncidentVerstoringResolveRate = S.IncidentVerstoringResolveRate
	, IncidentFirstlineDuration = S.IncidentFirstlineDuration
	, IncidentSecondlineDuration = S.IncidentSecondlineDuration
	, StandardChangeDurationRate = S.StandardChangeDurationRate
	, IncidentVerstoringP1ResolveRate = S.IncidentVerstoringP1ResolveRate
	, IncidentVerstoringP2ResolveRate = S.IncidentVerstoringP2ResolveRate
	, IncidentVerstoringP3ResolveRate = S.IncidentVerstoringP3ResolveRate
	, IncidentAanvraagP5ResolveRate = S.IncidentAanvraagP5ResolveRate
	, IncidentVraagP5ResolveRate = S.IncidentVraagP5ResolveRate
	, KlachtResolveRate = S.KlachtResolveRate
	, ProblemResolveRate = S.ProblemResolveRate
	, ChangeAuthTimeValue = S.ChangeAuthTimeValue
	, ChangeAuthTimeRate = S.ChangeAuthTimeRate
	, ChangeClosingTimeValue = S.ChangeClosingTimeValue
	, ChangeClosingTimeRate = S.ChangeClosingTimeRate
	, LastChgDateTime = S.LastChgDateTime
FROM
	[$(MDS)].mdm.DimSLA S -- Source
	INNER JOIN [$(OGDW)].Dim.SLA T -- Target
		ON S.Code = T.Code AND S.LastChgDateTime > T.LastChgDateTime -- Alleen nieuwere records aanpassen

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