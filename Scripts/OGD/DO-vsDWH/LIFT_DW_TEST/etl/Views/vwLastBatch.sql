CREATE VIEW etl.vwLastBatch
AS

SELECT
	*
FROM
	etl.ProcedureLog
WHERE 1=1
	AND Batch = (SELECT MAX(Batch) FROM etl.ProcedureLog)