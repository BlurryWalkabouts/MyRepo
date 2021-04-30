CREATE PROCEDURE [etl].[Log]
(
	@Procedure int
)
AS
BEGIN

-- Script: Log
-- Nota:   Simple logging procedure
--         If called from a regular sproc, inserts result of 1 (success) and the amount of rows processed.
--         If called from a try/catch block, inserts result of 0 (failure) and the error message.
-- Author: Pieter Simoons, jan 2017
-- Review:

INSERT INTO
	etl.ProcedureLog
	(
	Batch
	, [Time]
	, Script
	, Success
	, [Message]
	)
SELECT
	Batch = (SELECT MAX(COALESCE(Batch,0)) FROM etl.ProcedureLog)
	, [Time] = GETDATE()
	, Script = COALESCE(CAST(OBJECT_NAME(@Procedure) AS varchar(40)), '')
	, Success = CASE WHEN ERROR_MESSAGE() IS NULL THEN 1 ELSE 0 END
	, [Message] = COALESCE(CAST(ERROR_MESSAGE() AS varchar(100)), CAST(@@ROWCOUNT AS varchar(10)) + ' records processed.')

RETURN 0

END