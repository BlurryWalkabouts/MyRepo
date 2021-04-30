CREATE PROCEDURE [log].[UpdateProcLogRecord]
(
	@LogID int
	, @Message nvarchar(512)
	, @Success bit = 0
	, @RowCount int = 0
--	, @Error int = NULL
)
AS
BEGIN

-- Onderstaande is aangepast omdat 1750 twee meldingen betreft. Omdat we enkel de laatste melding kunnen 
-- loggen is @message aangevuld met extra info om probleem te verduidelijken 
SET @Message = IIF(ERROR_NUMBER() = 1750
	, 'Msg 2714, Level 16, State 5, Line 24 There is already an object in the database.'
	, @Message)

RAISERROR (@Message, 0, 1) WITH NOWAIT

DECLARE @EndDate datetime = GETDATE()

UPDATE
	[log].ProcedureLog
SET
	EndDate = @EndDate
	, RunningTime = DATEDIFF(MS, StartDate, @EndDate)
	, Success = @Success
	, RowsCount = @RowCount
	, ErrorNumber = ERROR_NUMBER()
	, ErrorMessage = ERROR_MESSAGE()
	, AdditionalInfo = CASE
			WHEN ERROR_NUMBER() IS NOT NULL THEN CONCAT('ErrorLine: ', ERROR_LINE(), '. ErrorSeverity: ', ERROR_SEVERITY(), '. ErrorState: ', ERROR_STATE())
			ELSE @Message 
		END
WHERE 1=1
	AND LogID = @LogID

END