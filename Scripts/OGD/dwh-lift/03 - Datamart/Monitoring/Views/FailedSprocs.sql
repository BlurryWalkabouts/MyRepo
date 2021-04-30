CREATE VIEW [Monitoring].[FailedSprocs]
AS

SELECT
	StartDate
	, ProcedureName
	, ErrorNumber
	, ErrorMessage
	, AdditionalInfo
FROM
	[Log].ProcedureLog
WHERE 1<>1
	OR ErrorNumber IS NOT NULL
	OR AdditionalInfo LIKE '%FAILED%'