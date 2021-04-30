CREATE PROCEDURE [Load].[LoadDimProject]
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

DELETE FROM Dim.Project

DBCC CHECKIDENT ('Dim.Project', RESEED, 40000000)

PRINT 'Inserting unknowns into Dim.Project'
SET IDENTITY_INSERT Dim.Project ON
INSERT INTO
	Dim.Project
	(
	ProjectKey
	, ProjectNumber
	, ProjectName
	, CustomerKey
	, OperatorKey
	, ProductGroup
	, Product
	, ProjectGroupNumber
	, ProjectGroupName
	, Office
	, ProjectPrice
	, ProjectLedgerKey
	, ProjectLedgerNumber
	)
SELECT
	ProjectKey = -1
	, ProjectNumber = '[unknown]'
	, ProjectName = '[unknown]'
	, CustomerKey = -1
	, OperatorKey = -1
	, ProductGroup = '[unknown]'
	, Product = '[unknown]'
	, ProjectGroupNumber = '[unknown]'
	, ProjectGroupName = '[unknown]'
	, Office = '[unknown]'
	, ProjectPrice = 0
	, ProjectLedgerKey = -1
	, ProjectLedgerNumber = '[unknown]'
SET IDENTITY_INSERT Dim.Project OFF

PRINT 'Inserting data into Dim.Project'
INSERT INTO
	Dim.Project
	(
	unid
	, ProjectNumber
	, ProjectName
	, CustomerKey
	, OperatorKey
	, ProductGroup
	, Product
	, ProjectGroupNumber
	, ProjectGroupName
	, ProjectStatus
	, ProjectStartDate
	, ProjectEndDate
	, ProjectCreationDate
	, ProjectChangeDate
	, ProjectAcceptDate
	, ProjectArchiveDate
	, Office
	, SalesTarget
	, ProjectPrice
	, HasEnded
	, ProjectLedgerKey
	, ProjectLedgerNumber
	)
SELECT
	unid = p.unid
	, ProjectNumber = p.projectnr
	, ProjectName = LTRIM(RTRIM(p.projectnaam))
	, CustomerKey = COALESCE(c.CustomerKey, -1)
	, OperatorKey = COALESCE(e.EmployeeKey, -1)
	, ProductGroup = bh.tekst
	, Product = d.naam
	, ProjectGroupNumber = pg.projectgroepnr
	, ProjectGroupName = LTRIM(RTRIM(pg.naam))
	, ProjectStatus = p.[status]
	, ProjectStartDate = p.startdatum
	, ProjectEndDate = p.einddatum
	, ProjectCreationDate = p.dataanmk
	, ProjectChangeDate = p.datwijzig
	, ProjectAcceptDate = p.datacceptatie
	, ProjectArchiveDate = p.archiefdatum
        , Office = p.vestiging
	, SalesTarget = p.sales_target
	, ProjectPrice = p.fprojectprijs
	, HasEnded = p.beeindigd
	, ProjectLedgerKey = COALESCE(l.LedgerKey, -1)
	, ProjectLedgerNumber = COALESCE(l.Text, '[unknown]')
FROM
	[archive].project p
	LEFT OUTER JOIN [archive].projectgroep pg ON p.projectgroepid = pg.unid
	LEFT OUTER JOIN Dim.Customer c ON c.unid = pg.klantid
	LEFT OUTER JOIN [archive].behandelaar b ON b.unid = p.behandeldid
	LEFT OUTER JOIN [archive].gebruiker g ON g.unid = b.gebruikerid
	LEFT OUTER JOIN [archive].werknemer w ON w.unid = g.employeeid
	LEFT OUTER JOIN Dim.Employee e ON e.unid = w.unid
	LEFT OUTER JOIN [archive].budgethouder bh ON bh.unid = p.productgroepid
	LEFT OUTER JOIN [archive].dienst d ON d.unid = p.productid
	LEFT OUTER JOIN Dim.Ledger l ON d.grootboekid = l.unid

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