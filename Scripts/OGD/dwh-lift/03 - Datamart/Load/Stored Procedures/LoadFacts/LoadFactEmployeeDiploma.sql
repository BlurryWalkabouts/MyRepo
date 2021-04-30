CREATE PROCEDURE [Load].[LoadFactEmployeeDiploma]
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

DELETE FROM Fact.EmployeeDiploma

PRINT 'Inserting data into Fact.EmployeeDiploma'

INSERT INTO 
	Fact.EmployeeDiploma
	(
	unid
	, EmployeeKey
	, DiplomaKey
	, ExpirationDate
	)
SELECT
	unid = wd.unid
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, DiplomaKey = COALESCE(d.DiplomaKey, -1)
	, ExpirationDate = wd.expiration_date
FROM
	[archive].werknemerdiploma wd
	LEFT OUTER JOIN Dim.Employee e ON e.unid = wd.werknemerid
	LEFT OUTER JOIN Dim.Diploma d ON d.unid = wd.diplomaid

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