CREATE PROCEDURE [Load].[LoadDimCustomer]
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

DELETE FROM Dim.Customer

DBCC CHECKIDENT ('Dim.Customer', RESEED, 10000000)

PRINT 'Inserting unknowns into Dim.Customer'
SET IDENTITY_INSERT Dim.Customer ON
INSERT INTO
	Dim.Customer
	(
	CustomerKey
	, AccountManagerKey
	, CustomerDebitNumber
	, CustomerFullname
	, CustomerPostcode
	, CustomerAddress
	, CustomerCity
	, CustomerCountry
	, CustomerCompanySize
	)
SELECT
	CustomerKey = -1
	, AccountManagerKey = -1
	, CustomerDebitNumber = '[unknown]'
	, CustomerFullname = '[unknown]'
	, CustomerPostcode = '[unknown]'
	, CustomerAddress = '[unknown]'
	, CustomerCity = '[unknown]'
	, CustomerCountry = '[unknown]'
	, CustomerCompanySize = '[unknown]'
SET IDENTITY_INSERT Dim.Customer OFF

PRINT 'Inserting data into Dim.Customer'
INSERT INTO
	Dim.Customer
	(
	unid
	, CustomerDebitNumber
	, CustomerFullname
	, AccountManagerKey
	, CustomerPostcode
	, CustomerAddress
	, CustomerCity
	, CustomerRegion
	, CustomerCountry
	, CustomerCompanySize
	, VATNumber
	, CoCNumber
	, CustomerStatus
	)
SELECT
	unid = k.unid
	, CustomerDebitNumber = k.debnr
	, CustomerFullname = k.bedrijf
	, AccountManagerKey = COALESCE(am.AccountManagerKey, -1)
	, CustomerPostcode = k.postcode1
	, CustomerAddress = COALESCE(k.straat1 + ' ' + k.nummer1, k.straat1, '[unknown]')
	, CustomerCity = k.plaats1
	, CustomerRegion = COALESCE(k.regio, '[unknown]')
	, CustomerCountry = k.land1
	, CustomerCompanySize = k.grootte
	, VATNumber = k.btwnr
	, CoCNumber = k.kvknr
	, CustomerStatus = k.[status]
FROM
    [archive].klant k
	LEFT OUTER JOIN Dim.AccountManager am ON am.unid = k.behandelaarid

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