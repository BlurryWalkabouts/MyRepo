CREATE PROCEDURE [Load].[LoadFactEmployeeContract]
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

DELETE FROM Fact.EmployeeContract

DBCC CHECKIDENT ('Fact.EmployeeContract', RESEED, 70000000)

PRINT 'Inserting unknowns into Fact.EmployeeContract'
SET IDENTITY_INSERT Fact.EmployeeContract ON
INSERT INTO
	Fact.EmployeeContract
	(
	EmployeeContractKey
	, EmployeeKey
	, EmployeeFullName
	, BusinessUnit
	, [Function]
	, ManagerKey
	, ManagerFullName
	, HRRepresentativeKey
	, HRRepresentativeFullName
	, ContractCreationDate
	, ContractChangeDate
	, ContractStatus
	, ContractType
	, [Percentage]
	, ContractStartDate
	, ContractEndDate
	, ContractDuration
	, SuggestedHourlyRate
	)
SELECT
	EmployeeContractKey = -1
	, EmployeeKey = -1
	, EmployeeFullname = 'Unknown'
	, BusinessUnit = 'Unknown'
	, [Function] = 'Unknown'
	, ManagerKey = -1
	, ManagerFullName = 'Unknown'
	, HRRepresentativeKey = -1
	, HRRepresentativeFullName = 'Unknown'
	, ContractCreationDate = '99991231'
	, ContractChangeDate = '99991231'
	, ContractStatus = 0
	, ContractType = '[unknown]'
	, [Percentage] = -1
	, ContractStartDate = '99991231'
	, ContractEndDate = '99991231'
	, ContractDuration = -1
	, SuggestedHourlyRate = -1
SET IDENTITY_INSERT Fact.EmployeeContract OFF

PRINT 'Inserting data into Fact.EmployeeContract'
INSERT INTO
	Fact.EmployeeContract
	(
	unid
	, EmployeeKey
	, EmployeeFullName
	, BusinessUnit
	, [Function]
	, ManagerKey
	, ManagerFullName
	, HRRepresentativeKey
	, HRRepresentativeFullName
	, ContractCreationDate
	, ContractChangeDate
	, ContractStatus
	, ContractType
	, [Percentage]
	, ContractStartDate
	, ContractEndDate
	, ContractDuration
	, SuggestedHourlyRate
	)
SELECT
	unid = wc.unid
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, EmployeeFullName = COALESCE(e.FullName, 'Unknown')
	, BusinessUnit = COALESCE(e.BusinessUnit, 'Unknown')
	, [Function] = COALESCE(e.[Function], 'Unknown')
	, ManagerKey = COALESCE(e.ManagerKey, -1)
	, ManagerFullName = COALESCE(e.Manager, 'Unknown')
	, HRRepresentativeKey = COALESCE(e.HRRepresentativeKey, -1)
	, HRRepresentativeFullName = COALESCE(e.HRRepresentative, 'Unknown')
	, ContractCreationDate = wc.dataanmk
	, ContractChangeDate = wc.datwijzig
	, ContractStatus = wc.[status]
	, ContractType = wc.contractsoort
	, [Percentage] = wc.procent
	, ContractStartDate = wc.startdatum
	, ContractEndDate = wc.einddatum
	, ContractDuration = DATEDIFF(YEAR, 
	    (CAST(wc.[startdatum] AS DATETIME2) AT TIME ZONE 'Central European Standard Time'),
		CASE WHEN wc.einddatum < (SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time') 
            THEN wc.einddatum 
		    ELSE SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time' 
		END
		)
	, SuggestedHourlyRate = wc.uurtarief
FROM 
	[archive].wcontract wc
	LEFT OUTER JOIN Dim.Employee e ON e.unid = wc.werknemerid

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