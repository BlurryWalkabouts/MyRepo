CREATE PROCEDURE [Load].[LoadFactHour]
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

DELETE FROM Fact.[Hour]

PRINT 'Inserting data into Fact.Hour'

INSERT INTO
	Fact.[Hour]
	(
	unid
	, ProjectKey
	, CustomerKey
	, EmployeeKey
	, HourTypeKey
	, ServiceKey
	, LedgerKey
	, NominationKey
	, TaskKey
	, HourInvoiceKey
	, [Hours]
	, [Day]
	, ChangeDate
	, Rate
	, [Percentage]
	, Billable
	, InvoiceProcessed
	)

/* Inserting project hours */
SELECT
	unid = u.unid
	, ProjectKey = COALESCE(p.ProjectKey, -1)
	, CustomerKey = COALESCE(c.CustomerKey, -1)
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, HourTypeKey = COALESCE(ht.HourTypeKey, -1)
	, ServiceKey = COALESCE(s.ServiceKey, -1)
	, LedgerKey = COALESCE(l.LedgerKey, -1)
	, NominationKey = COALESCE(n.NominationKey, -1)
	, TaskKey = COALESCE(n.TaskKey, -1)
	, HourInvoiceKey = COALESCE(i.InvoiceKey, -1)
	, [Hours] = COALESCE(u.seconds / 3600.0, u.old_amount)
	, [Day] = CAST(u.datum AS date)
	, ChangeDate = CAST(u.datwijzig AS date)
	, Rate = v.uurprijs
	, [Percentage] = ht.[Percentage]
	, Billable = ht.Billable
	, InvoiceProcessed = u.verwerkt_factuur
FROM
    [archive].assignment_hour u
    LEFT OUTER JOIN [archive].uurtype ut ON ut.unid = u.hourtypeid
	LEFT OUTER JOIN Dim.Project p ON p.unid = ut.projectid
	LEFT OUTER JOIN Dim.Customer c ON c.CustomerKey = p.CustomerKey
    LEFT OUTER JOIN [archive].voordracht v ON v.unid = U.assignmentid
    LEFT OUTER JOIN [archive].dienst d ON v.productid = d.unid
	LEFT OUTER JOIN Dim.Employee e ON e.unid = v.employeeid
--		AND U.datum > E.ContractStartDate AND U.datum < E.ContractEndDate -- Disabled these conditions on 17-07-2017; this caused '-1' for ~25% of the cases for the EmployeeKey
    LEFT OUTER JOIN [archive].klant k ON k.unid = c.unid
	LEFT OUTER JOIN Dim.AccountManager am ON am.unid = k.behandelaarid
	LEFT OUTER JOIN Dim.HourType ht ON ht.Billable = ut.declarabel AND ht.[Percentage] = ut.procent AND ht.RateName = ut.tariefnaam
	LEFT OUTER JOIN Dim.[Service] s ON s.ProductNomination = d.naam
	LEFT OUTER JOIN Dim.Ledger l ON l.unid = v.grootboekid
	LEFT OUTER JOIN Dim.Nomination n ON n.unid = v.unid
	LEFT OUTER JOIN Dim.Invoice i ON i.InvoiceSourceId = u.seen_by_invoice_id
WHERE 1=1
	AND u.datum > '2010-01-01'

UNION

/* Inserting task hours */
SELECT
	unid = u.unid
	, ProjectKey = -1
	, CustomerKey = -1
	, EmployeeKey = COALESCE(n.EmployeeKey, -1)
	, HourTypeKey = -1
	, ServiceKey = -1
	, LedgerKey = -1
	, NominationKey = COALESCE(n.NominationKey, -1)
	, TaskKey = COALESCE(n.TaskKey, -1)
	, HourInvoiceKey = -1
	, [Hours] = COALESCE(u.seconds / 3600.0, u.old_amount)
	, [Day] = CAST(u.datum AS date)
	, ChangeDate = CAST(u.datwijzig AS date)
	, Rate = 0 -- Tasks do not generate turnover
	, [Percentage] = 100
	, Billable = 0
	, InvoiceProcessed = 0
FROM
    [archive].task_assignment_hour u
	LEFT OUTER JOIN Dim.Nomination n ON n.unid = u.task_assignmentid
WHERE 1=1
	AND u.datum > '2010-01-01'

UNION

/* Inserting generic task hours */
SELECT
	unid = u.unid
	, ProjectKey = -1
	, CustomerKey = -1
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, HourTypeKey = -1
	, ServiceKey = -1
	, LedgerKey = -1
	, NominationKey = COALESCE(n.NominationKey, -1)
	, TaskKey = COALESCE(t.TaskKey, -1)
	, HourInvoiceKey = -1
	, [Hours] = COALESCE(u.seconds / 3600.0, u.old_amount)
	, [Day] = CAST(u.datum AS date)
	, ChangeDate = CAST(u.datwijzig AS date)
	, Rate = 0 -- Tasks do not generate turnover
	, [Percentage] = 100
	, Billable = 0
	, InvoiceProcessed = 0
FROM
    [archive].task_hour u
	LEFT OUTER JOIN Dim.Employee e ON e.unid = u.employeeid
	LEFT OUTER JOIN Dim.Task t ON t.unid = u.taskid
	LEFT OUTER JOIN Dim.Nomination n ON n.EmployeeKey = e.EmployeeKey AND n.TaskKey = t.TaskKey
WHERE 1=1
	AND u.datum > '2010-01-01'

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