-- Script: Log
-- Nota:   Simple logging procedure
--         If called from a regular sproc, inserts result of 1 (success) and the amount of rows processed.
--         If called from a try/catch block, inserts result of 0 (failure) and the error message.
-- Author: Luit Wit

CREATE PROCEDURE [log].[Log]
(
	@ProcedureID int
	, @StartTime DATETIME2 = NULL
)
AS
BEGIN

INSERT INTO
	[log].ProcedureLog
	(
	[Batch]			
	, [Starttijd]		
	, [Eindtijd]		
	, [Script]		
	, [IsGeslaagd]	
	, [Melding]		
	)
SELECT
	[Batch] = (SELECT MAX(COALESCE(Batch,0)) FROM [log].ProcedureLog)
	, [Starttijd] = @StartTime
	, [Eindtijd] = GETDATE()
	, [Script] = COALESCE(CAST(OBJECT_NAME(@ProcedureID) AS varchar(40)), '')
	, [IsGeslaagd] = CASE WHEN ERROR_MESSAGE() IS NULL THEN 1 ELSE 0 END
	, [Melding] = COALESCE(CAST(ERROR_MESSAGE() AS varchar(200)), CAST(@@ROWCOUNT AS varchar(10)) + ' rows affected.')
RETURN 0

END