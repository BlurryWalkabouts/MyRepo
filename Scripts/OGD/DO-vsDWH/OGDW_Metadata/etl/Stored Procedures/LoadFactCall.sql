CREATE PROCEDURE [etl].[LoadFactCall]
AS
BEGIN

/***************************************************************************************************
* Fact.Call
****************************************************************************************************
*
***************************************************************************************************/

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

--TRUNCATE TABLE [$(OGDW)].Fact.[Call]

INSERT INTO
	[$(OGDW)].Fact.[Call]
	(
	CallSummaryID
	, CustomerKey
	, StartDateKey
	, StartTimeKey
	, InQueueDateKey
	, InQueueTimeKey
	, AcceptedDateKey
	, AcceptedTimeKey
	, EndDateKey
	, EndTimeKey
	, UCCName
	, [Caller]
	, StartTime
	, InQueueTime
	, AcceptedTime
	, EndTime
	, Accepted
	, CallDuration
	, CallTotalDuration
	, QueueDuration
	, SkillChosen
	, InitialAgent
	, Handled
	, DWDateCreated
	)
SELECT DISTINCT
	C.CallSummaryID
	, CustomerKey = ISNULL(C1.Code,-1)
	, C.StartDateKey
	, C.StartTimeKey
	, C.InQueueDateKey
	, C.InQueueTimeKey
--	, C.QueueTime
	, C.AcceptedDateKey
	, C.AcceptedTimeKey
--	, C.AcceptedTime
	, C.EndDateKey
	, C.EndTimeKey
--	, C.EndTime
	, C.UCCName
	, C.[Caller]
	, C.StartTime
	, C.InQueueTime
	, C.AcceptedTime
	, C.EndTime
	, C.Accepted
	, C.CallDuration
	, C.CallTotalDuration
	, C.QueueDuration
	, C.SkillChosen
	, C.InitialAgent
	, C.Handled
	, C.DWDateCreated
FROM
	etl.Translated_Call C
	LEFT OUTER JOIN setup.AnywhereSkillTranslation AST ON AST.[Name] = C.SkillChosen
	LEFT OUTER JOIN setup.DimCustomer C1 ON C1.Code = AST.Customer_Code

/* Omdat we weten dat de regels altijd op volgorde worden aangemaakt kunnen we heel snel de nieuwe regels eruit filteren */

WHERE 1=1

/*
Endtime filter gebruiken we niet meer omdat het voorkomt dat calls met een delay weggeschreven worden in de db.
Hierdoor loop je het risico dat er calls niet in de fact tabel komen omdat ze een eerdere endtime hebben dan de laatste endtime van de fact table

--	We gebruiken >= omdat in theorie 2 telefoontjes op dezelfde tijd (afgerond) zijn binnengekomen, maar niet allemaal zijn ingelezen
	AND endtime >= (SELECT MAX(endtime) FROM [$(OGDW)].Fact.[Call])
*/

-- Bestaande regels (op dezelfde tijd) filteren
	AND CallSummaryID NOT IN (SELECT CallSummaryID FROM [$(OGDW)].Fact.[Call])

-- Extra filter om de selectie te versnellen, de kans dat de hierboven genoemde uitzondering na meer dan 2 dagen pas binnenkomt is nihil.
--	AND EndTime > GETDATE() - 2

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