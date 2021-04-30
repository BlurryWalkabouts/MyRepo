CREATE PROCEDURE [etl].[LoadFactTelefonieStoringen]
AS
BEGIN

-- ================================================
-- Create fact table for Telefoniestoringen.
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

DELETE FROM [$(OGDW)].Fact.Telefoniestoringen

INSERT INTO
	[$(OGDW)].Fact.Telefoniestoringen
SELECT 
	Code
	, StartDateKey = D1.DateKey
	, EndDateKey = D2.DateKey
	, StartTimeKey = T1.TimeKey
	, EndTimeKey = T2.TimeKey
	, [Name]
	, Classificatie_Name
	, Oorzaak_Name
-- Gedaan om de velden Startdatum en Starttijd samen te voegen, MDS ondersteund geen datumtijd veld
	, [Start] = DATEADD(MI, DATEPART(MI,CAST(StartTijd AS time)), DATEADD(HH, DATEPART(HH,CAST(StartTijd AS time)), StartDatum)) -- CAST(StartDatum AS date)
-- Gedaan om de velden Startdatum en Starttijd samen te voegen, MDS ondersteund geen datumtijd veld
	, Eind = DATEADD(MI, DATEPART(MI,CAST(EindTijd AS time)), DATEADD(HH, DATEPART(HH,CAST(EindTijd AS time)), EindDatum)) -- CAST(EindDatum AS date)
FROM
	[$(MDS)].mdm.DimTelefonieStoringen S
	LEFT OUTER JOIN [$(OGDW)].Dim.[Date] D1 ON CAST(S.StartDatum AS date) = D1.[Date]
	LEFT OUTER JOIN [$(OGDW)].Dim.[Date] D2 ON CAST(S.EindDatum AS date) = D2.[Date]
	LEFT OUTER JOIN [$(OGDW)].Dim.[Time] T1 ON CAST(S.StartTijd AS time) = T1.[Time]
	LEFT OUTER JOIN [$(OGDW)].Dim.[Time] T2 ON CAST(S.StartTijd AS time) = T2.[Time]

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