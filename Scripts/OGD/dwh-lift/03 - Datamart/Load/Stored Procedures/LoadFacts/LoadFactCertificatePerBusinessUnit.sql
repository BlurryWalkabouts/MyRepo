CREATE PROCEDURE [Load].[LoadFactCertificatePerBusinessUnit]
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

DELETE FROM Fact.CertificatePerBusinessUnit

PRINT 'Inserting data into Fact.CertificatePerBusinessUnit'
INSERT INTO
	Fact.CertificatePerBusinessUnit
	(
	BusinessUnit
	, Team
	, Diploma
	, DiplomaKey
	, ExpirationDate
	, DiplomaCount
	)
SELECT
	BusinessUnit     = COALESCE(E.BusinessUnit, '[unknown]')
	, Team           = COALESCE(E.Team, '[unknown]')
    , Diploma        = D.Diploma
	, DiplomaKey     = D.DiplomaKey
    , ExpirationDate = COALESCE(ED.ExpirationDate, '99991231')
	, DiplomaCount   = COUNT(D.DiplomaKey)
FROM
    [Fact].[EmployeeDiploma] ED
    INNER JOIN [Dim].[Diploma] D ON D.DiplomaKey = ED.DiplomaKey
        AND D.Diploma NOT LIKE 'HBO%'
    	AND D.Diploma NOT LIKE 'WO%'
    INNER JOIN [Dim].[Employee] E ON E.EmployeeKey = ED.EmployeeKey
    	AND HasActiveContract = 1
GROUP BY
    E.BusinessUnit
	, E.Team
	, D.Diploma
	, D.DiplomaKey
	, ED.ExpirationDate

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