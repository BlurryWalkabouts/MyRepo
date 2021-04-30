CREATE PROCEDURE [Log].[NewProcLogRecord]
(
	@LogID int OUTPUT
	, @SessionID int
	, @ObjectID int
	, @Message nvarchar(512)
)
AS
BEGIN

DECLARE @StartDate datetime = GETDATE()
DECLARE @DatabaseID int
DECLARE @ProcedureName nvarchar(max)
DECLARE @LoginName nvarchar(50)

-- Zoek de DatabaseID op aan de hand van het SessionID
SELECT
	@DatabaseID = s.database_id
	, @LoginName = s.login_name
FROM
	sys.dm_exec_sessions s
WHERE 1=1
	AND s.session_id = @SessionID

SET @ProcedureName = COALESCE(QUOTENAME(DB_NAME(@DatabaseID)) + '.' + QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectID, @DatabaseID)) + '.' + QUOTENAME(OBJECT_NAME(@ObjectID, @DatabaseID)), ERROR_PROCEDURE())

INSERT
	[Log].ProcedureLog
	(
	DatabaseID
	, ObjectID
	, ProcedureName
	, LoginName
	, StartDate
	, AdditionalInfo
	)
SELECT
	DatabaseID = @DatabaseID
	, ObjectID = @ObjectID
	, ProcedureName = @ProcedureName
	, LoginName = @LoginName
	, StartDate = @StartDate
	, AdditionalInfo = @Message 

SET @LogID = SCOPE_IDENTITY()

END