CREATE PROCEDURE [Load].[LoadDimInvoice]
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

DELETE FROM Dim.Invoice

DBCC CHECKIDENT ('Dim.Invoice', RESEED, 15000000)

PRINT 'Inserting unknowns into Dim.Invoice'
SET IDENTITY_INSERT Dim.Invoice ON
INSERT INTO
	Dim.Invoice
	(
	InvoiceKey
	, InvoiceNumber
	, InvoiceCustomerKey
	, InvoiceProjectKey
	, InvoiceAmountExVat
	, InvoiceVat
	, InvoiceAmountIncVat
	, InvoiceDatePeriodStarted
	, InvoiceDatePeriodEnded
	, InvoiceDateDocumentCreated
	, InvoiceDueTermInDays
	)
SELECT
	Invoicekey = -1
	, InvoiceNumber = '[unknown]'
	, InvoiceCustomerKey = -1
	, InvoiceProjectKey = -1
	, InvoiceAmountExVat = 0
	, InvoiceVat = 0
	, InvoiceAmountIncVat = 0
	, InvoiceDatePeriodStarted = '17530101'
	, InvoiceDatePeriodEnded = '17530101'
	, InvoiceDateDocumentCreated = '17530101'
	, InvoiceDueTermInDays = 0

SET IDENTITY_INSERT Dim.Invoice OFF

PRINT 'Inserting data into Dim.Invoice'
INSERT INTO
	Dim.Invoice
	(
	InvoiceNumber
	, InvoiceSourceId
	, InvoiceCustomerKey
	, InvoiceProjectKey
	, InvoiceAmountExVat
	, InvoiceVat
	, InvoiceAmountIncVat
	, InvoiceDatePeriodStarted
	, InvoiceDatePeriodEnded
	, InvoiceDateDocumentCreated
	, InvoiceDueTermInDays
	, InvoiceDocumentId
	)
SELECT
	InvoiceNumber					= COALESCE(i.invoicenr, '[unknown]')
	, InvoiceSourceId				= i.unid
	, InvoiceCustomerKey			= COALESCE(p.CustomerKey, -1)
	, InvoiceProjectKey				= COALESCE(p.ProjectKey, -1)
	, InvoiceAmountExVAT			= COALESCE(i.price_ex_vat, 0)
	, InvoiceVAT					= COALESCE(i.vat_price, 0)
	, InvoiceAmountIncVat			= COALESCE(i.price_ex_vat, 0) + COALESCE(i.vat_price, 0)
	, InvoiceDatePeriodStarted		= COALESCE(i.start_span, '17530101')
	, InvoiceDatePeriodEnded		= COALESCE(i.end_span, '17530101')
	, InvoiceDateDocumentCreated	= COALESCE(i.document_date, '17530101')
	, InvoiceDueTermInDays			= COALESCE(b.vervaltermijn, 0)
	, InvoiceDocumentId				= d.documentid
FROM
	[archive].invoice AS i
	LEFT OUTER JOIN Dim.Project p ON i.motherprojectid = p.unid
	LEFT OUTER JOIN Dim.Customer c ON i.debtorid = c.unid
	LEFT OUTER JOIN [archive].betalingsconditie b ON i.payment_conditionid = b.unid
	LEFT OUTER JOIN [archive].invoice_document_link d ON i.unid = d.invoiceid

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