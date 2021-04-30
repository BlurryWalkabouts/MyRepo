CREATE PROCEDURE [etl].[LoadDimNiceReply]
AS
BEGIN

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

DELETE FROM [$(OGDW)].Dim.NiceReply

;WITH cte AS
(
SELECT
	Reply_ID = created
	, CreationDate = CAST(DateCreated AS date)
	, CreationTime = CAST(DateCreated AS time(0))
	, TicketLink = ticket
	, TicketSource = CASE WHEN CHARINDEX('(', userName) > 0 THEN LEFT(userName, CHARINDEX('(', userName) - 2) ELSE userName END
	, TicketType = CASE WHEN ticket LIKE '%/incident?%' THEN 'incident' WHEN ticket LIKE '%/newchange?%' THEN 'change' ELSE '' END
	, TicketID = TRY_CAST(STUFF(STUFF(STUFF(STUFF(RIGHT(ticket,32),21,0,'-'),17,0,'-'),13,0,'-'),9,0,'-') AS uniqueidentifier)
	, IPAddress = ipAddr
	, Score = score
	, Comment = comment
	, RowNumber = ROW_NUMBER() OVER (PARTITION BY created ORDER BY DateCreated DESC)
FROM
	[$(OGDW_Staging)].NiceReply.Replies
WHERE 1=1
	AND deleted = 0
)

INSERT INTO
	[$(OGDW)].Dim.NiceReply
	(
	Reply_ID
	, SourceDatabaseKey
	, CreationDate
	, CreationTime
	, TicketLink
	, TicketType
	-- TicketID wordt nu nog als uniqueidentifier in de dimensie opgeslagen, terwijl we dit verder in geen enkele andere fact
	-- of dimensie doen.
	, TicketID
	, IPAddress
	, Score
	, Comment
	)
SELECT
	Reply_ID
	-- Feitelijk zou SDK het nummer van de brondatabase moeten bevatten (ergo: NiceReply), maar hier is SDK een verwijzing naar
	-- de bron waar het originele ticket uit komt. De hele methode om een beoordeling aan een ticket / behandelaar / aanmelder
	-- te koppelen, moet worden verbeterd.
	, SourceDatabaseKey = CASE TicketSource
			WHEN 'OGD' THEN 20
			WHEN 'MKBO' THEN 40
			WHEN 'Accare' THEN CASE TicketType WHEN 'incident' THEN 327 WHEN 'change' THEN 326 ELSE -1 END
			WHEN 'BPD' THEN CASE TicketType WHEN 'incident' THEN 328 WHEN 'change' THEN 329 ELSE -1 END
			WHEN '1ICT' THEN 342
			WHEN '--acceptatie--' THEN -1
			ELSE -1
		END
	, CreationDate
	, CreationTime
	, TicketLink
	, TicketType
	, TicketID
	, IPAddress
	, Score
	, Comment
FROM
	cte
WHERE 1=1
	AND RowNumber = 1

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