CREATE PROCEDURE [Load].[LoadDimRequest]
(
	@WriteLog bit = 1
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM Dim.Request

DBCC CHECKIDENT ('Dim.Request', RESEED, 130000000)

PRINT 'Inserting unknowns into Dim.Request'
SET IDENTITY_INSERT Dim.Request ON
INSERT INTO
	Dim.Request
	(
	RequestKey
	, ProjectKey
	, RequestNumber
	, RequestStatus
	, SalesChannel
	, RequestSalesTarget
	, SuccessChance
	)
SELECT
	RequestKey = -1
	, ProjectKey = -1
	, RequestNumber = '[unknown]'
	, RequestStatus = -1
	, SalesChannel = '[unknown]'
	, RequestSalesTarget = -1
	, SuccessChance = -1
SET IDENTITY_INSERT Dim.Request OFF

PRINT 'Inserting data into Dim.Request'
INSERT INTO 
	Dim.Request
	(
	unid
	, ProjectKey
	, RequestCreationDate
	, RequestChangeDate
	, RequestArchiveDate
	, RequestAcceptDate
	, RequestNumber
	, RequestStatus
	, SalesChannel
	, IsAdditionalRequest
	, RequestSalesTarget
	, SuccessChance
	, RequestValue
	)
SELECT
	unid = a.unid
	, ProjectKey = COALESCE(p.ProjectKey, -1)
	, RequestCreationDate = a.dataanmk
	, RequestChangeDate = a.datwijzig
	, RequestArchiveDate = a.archiefdatum
	, RequestAcceptDate = a.datacceptatie
	, RequestNumber = a.aanvraagnr
	, RequestStatus = a.[status]
	, SalesChannel = ap.sales_channel
	, IsAdditionalRequest = a.is_additional_request
	, RequestSalesTarget = a.amount_quoted
	, SuccessChance = a.slagingspercentage
	, RequestValue = a.amount_quoted * a.slagingspercentage / 100
FROM
	[archive].aanvraag a
	LEFT OUTER JOIN Dim.Project p ON a.projectid = p.unid 
	LEFT OUTER JOIN [archive].project ap ON a.projectid = ap.unid

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END