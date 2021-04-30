CREATE PROCEDURE [Load].[LoadFactInvoiceDetail]
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

DELETE FROM Fact.[InvoiceDetail]

PRINT 'Inserting data into Fact.InvoiceDetail'

; WITH Invoices AS (
	SELECT
		InvoiceSourceId	= e.invoiceid
		, InvoiceDate	= e.booking_date
		, LedgerKey		= l.LedgerKey
		, InvoiceType	= 'Uurbasis'
	FROM
		[archive].invoiced_employee_hour		AS e
		LEFT OUTER JOIN [archive].voordracht	AS v ON v.unid = e.employee_assignment_id
		LEFT OUTER JOIN Dim.Ledger					AS l ON l.unid = v.grootboekid
	UNION ALL
	SELECT
		InvoiceSourceId	= f.invoiceid
		, InvoiceDate	= f.booking_date
		, LedgerKey		= -1
		, InvoiceType	= 'Factuurplanning'
	FROM
		[archive].invoiced_fixed_price AS f
	UNION ALL
	SELECT
		InvoiceSourceId	= p.invoiceid
		, InvoiceDate	= p.booking_date
		, LedgerKey		= -1
		, InvoiceType	= 'Factuurplanning'
	FROM
		[archive].invoiced_invoiceplanning AS p
)

INSERT INTO
	Fact.[InvoiceDetail]
	(
	InvoiceDetailInvoiceKey
	, InvoiceDetailNumber
	, InvoiceDetailSourceId
	, InvoiceDetailProjectKey
	, InvoiceDetailDateDocumentBooked
	, InvoiceDetailAmountExVAT
	, InvoiceDetailVAT
	, InvoiceDetailAmountIncVat
	, InvoiceDetailDateDocumentCreated
	, InvoiceDetailDatePeriodStarted
	, InvoiceDetailDatePeriodEnded
	, InvoiceDetailDueTermInDays
	, InvoiceDetailCustomerKey
	, InvoiceDetailLedgerKey
	, InvoiceDetailType
	, InvoiceDetailDocumentId
	)

/* Inserting project hours */
SELECT
	InvoiceDetailInvoiceKey				= d.InvoiceKey
	, InvoiceDetailNumber				= COALESCE(d.InvoiceNumber, '[unknown]')
	, InvoiceDetailSourceId				= i.InvoiceSourceId
	, InvoiceDetailProjectKey			= COALESCE(d.InvoiceProjectKey, -1)
	, InvoiceDetailDateDocumentBooked	= COALESCE(i.InvoiceDate, '17530101')
	, InvoiceDetailAmountExVAT			= COALESCE(d.InvoiceAmountExVat, 0)
	, InvoiceDetailVAT					= COALESCE(d.InvoiceVat, 0)
	, InvoiceDetailAmountIncVat			= COALESCE(d.InvoiceAmountExVat, 0) + COALESCE(d.InvoiceVat, 0)
	, InvoiceDetailDateDocumentCreated	= COALESCE(d.InvoiceDateDocumentCreated, '17530101')
	, InvoiceDetailDatePeriodStarted	= COALESCE(d.InvoiceDatePeriodStarted, '17530101')
	, InvoiceDetailDatePeriodEnded		= COALESCE(d.InvoiceDatePeriodEnded, '17530101')
	, InvoiceDetailDueTermInDays		= COALESCE(d.InvoiceDueTermInDays, 0)
	, InvoiceDetailCustomerKey			= COALESCE(d.InvoiceCustomerKey, -1)
	, InvoiceDetailLedgerKey			= COALESCE(i.LedgerKey, -1)
	, InvoiceDetailType					= COALESCE(i.InvoiceType, '[unknown]')
	, InvoiceDetailDocumentId			= d.InvoiceDocumentId
FROM
	Invoices AS i
	LEFT OUTER JOIN Dim.Invoice AS d ON i.InvoiceSourceId = d.InvoiceSourceId

WHERE 1=1
	AND i.InvoiceDate >= '20170101'

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