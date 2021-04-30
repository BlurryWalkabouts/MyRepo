CREATE PROCEDURE [monitoring].[LoadNewFailedFileImports]
AS
BEGIN

WITH FailedFileImports AS
(
SELECT
	operation_id
FROM
	[$(SSISDB)].internal.operation_messages
WHERE 1=1
	AND message_source_type = 40
	AND message_type = 40
	AND [message] LIKE 'Import Failed - Move and Rename File%'
)

, ErrorMessages AS
(
SELECT
	om.operation_id
	, [message] = REPLACE(om.[message],em.message_source_name+':','')
FROM
	[$(SSISDB)].internal.operation_messages om
	LEFT OUTER JOIN [$(SSISDB)].internal.event_messages em ON om.operation_message_id = em.event_message_id
WHERE 1=1
	AND om.message_source_type = 60
	AND om.message_type IN (110,120)
	AND (om.[message] LIKE '%removed%' OR om.[message] LIKE '%converted%' OR om.[message] LIKE '%potential loss%')
)

INSERT INTO
	monitoring.FailedFileImports
	(
	DWDateCreated
	, AuditDWKey
	, SourceDatabaseKey
	, DatabaseLabel
	, SourceFileType
	, ErrorMessage
	, ExpectedColumns
	)
SELECT
	a.DWDateCreated
	, a.AuditDWKey
	, a.SourceDatabaseKey
	, sd.DatabaseLabel
	, sd.SourceFileType
	, ErrorMessage = e.[message]
	, ExpectedColumns = STUFF((
		SELECT ', ' + c.ExpectedColumns
		FROM monitoring.CheckMissingColumns(a.SourceDatabaseKey, a.AuditDWKey) c
		FOR XML PATH('')), 1, 2, '')
FROM
	FailedFileImports i
	LEFT OUTER JOIN ErrorMessages e ON i.operation_id = e.operation_id
	INNER JOIN [log].[Audit] a ON i.operation_id = a.ServerExecutionID
	LEFT OUTER JOIN setup.SourceDefinition sd ON a.SourceDatabaseKey = sd.Code
WHERE 1=1
	AND a.AuditDWKey > (SELECT MAX(AuditDWKey) FROM monitoring.FailedFileImports)
ORDER BY
	AuditDWKey

END