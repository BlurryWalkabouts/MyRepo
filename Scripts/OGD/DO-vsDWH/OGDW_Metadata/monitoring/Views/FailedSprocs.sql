CREATE VIEW [monitoring].[FailedSprocs]
AS

SELECT
	StartDate
	, ProcedureName
	, ErrorNumber
	, ErrorMessage
	, AdditionalInfo
FROM
	[log].ProcedureLog
WHERE 1<>1
	OR ErrorNumber IS NOT NULL
	OR AdditionalInfo LIKE '%FAILED%'