CREATE PROCEDURE [log].[Log]
(
	@Message nvarchar(512)
	, @Success bit = 1
	, @RowCount int = NULL OUTPUT
--	, @Delimiter nchar(1) = N' '
	-- I.v.m. backward compatability zijn er default waarden voor @StartDate, @DatabaseID en @SessionID. Uiteindelijk zal @DatabaseID
	-- verdwijnen en is het de bedoeling dat @StartDate en @SessionID wel verplicht zijn.
	, @StartDate datetime = NULL
	, @DatabaseID int = NULL
	, @SessionID int = NULL
	, @ObjectID int
	, @Error int = NULL
)
AS
BEGIN

SET @RowCount = @@ROWCOUNT

DECLARE @EndDate datetime
DECLARE @ProcedureName nvarchar(max)
DECLARE @LoginName nvarchar(50)

-- Als er geen DatabaseID wordt meegestuurd, zoek deze dan op aan de hand van het SessionID. Uiteindelijk is het de bedoeling
-- dat het IF-statement verdwijnt, en het DatabaseID altijd wordt opgezocht aan de hand van het SessioID. Zie ook opmerking bij
-- parameters boven.
IF @DatabaseID IS NULL
	SELECT
		@DatabaseID = s.database_id
		, @LoginName = s.login_name
	FROM
		sys.dm_exec_sessions s
	WHERE 1=1
		AND s.session_id = @SessionID

-- Onderstaande is aangepast omdat 1750 twee meldingen betreft. Omdat we enkel de laatste melding kunnen 
-- loggen is @message aangevuld met extra info om probleem te verduidelijken 
SET @Message = IIF(ERROR_NUMBER() = 1750
	, 'Msg 2714, Level 16, State 5, Line 24 There is already an object in the database.'
	, @Message)

RAISERROR (@Message, 0, 1) WITH NOWAIT

SET @ProcedureName = COALESCE(QUOTENAME(DB_NAME(@DatabaseID)) + '.' + QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectID, @DatabaseID)) + '.' + QUOTENAME(OBJECT_NAME(@ObjectID, @DatabaseID)), ERROR_PROCEDURE())
SET @EndDate = GETDATE()

INSERT
	[log].ProcedureLog
	(
	DatabaseID
	, ObjectID
	, ProcedureName
	, LoginName
	, StartDate
	, EndDate
	, RunningTime
	, Success
	, RowsCount
	, ErrorNumber
	, ErrorMessage
	, AdditionalInfo
	)
SELECT
	DatabaseID = @DatabaseID
	, ObjectID = @ObjectID
	, ProcedureName = @ProcedureName
	, LoginName = @LoginName
	, StartDate = @StartDate
	, EndDate = @EndDate
	, RunningTime = DATEDIFF(MS, @StartDate, @EndDate)
	, Success = @Success
	, RowsCount = @RowCount
	, ErrorNumber = ERROR_NUMBER()
	, ErrorMessage = ERROR_MESSAGE()
	, AdditionalInfo = CASE
			WHEN ERROR_NUMBER() IS NOT NULL THEN CONCAT('ErrorLine: ', ERROR_LINE(), '. ErrorSeverity: ', ERROR_SEVERITY(), '. ErrorState: ', ERROR_STATE())
			ELSE @Message 
		END

END