CREATE PROCEDURE [Load].[LoadFactAppointment]
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

DELETE FROM Fact.Appointment

PRINT 'Inserting data into Fact.Appointment'

INSERT INTO
	Fact.Appointment
	(
	unid
	, OperatorKey
	, CustomerKey
	, ContactPersonKey
	, ProjectKey
	, RequestKey
	, [Status]
	, AppointmentDate
	, AppointmentCreationDate
	, Result
	, Category
	, AcquisitionGoal
	, AppointmentType
	, [Subject]
	)

/* Begin met ophalen van klantafspraken*/
SELECT
	unid = ac.unid
	, OperatorKey = COALESCE(acm.AccountManagerKey, -1)
	, CustomerKey = COALESCE(cu.CustomerKey, -1)
	, ContactPersonKey = -1
	, ProjectKey = -1
	, RequestKey = -1
	, [Status] = ac.[status]
	, AppointmentDate = ac.afspraaktijd
	, AppointmentCreationDate = ac.dataanmk
        , Result = ac.resultaat
        , Category = ac.wfcategorie
        , AcquisitionGoal = ac.acquisition_goal
	, AppointmentType = 'Customer'
	, [Subject] = NULL
FROM
	[archive].appointmentcustomer ac
	LEFT OUTER JOIN [archive].accountmanager am ON ac.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN Dim.Customer cu ON ac.customerid = cu.unid

UNION

/* Klant CP afspraken toevoegen */
SELECT
	unid = ac.unid
	, OperatorKey = COALESCE(acm.AccountManagerKey, -1)
	, CustomerKey = COALESCE(cu.CustomerKey, -1)
	, ContactPersonKey = COALESCE(cp.ContactPersonKey, -1)
	, ProjectKey = -1
	, RequestKey = -1
	, [Status] = ac.[status]
	, AppointmentDate = ac.afspraaktijd
	, AppointmentCreationDate = ac.dataanmk
        , Result = ac.resultaat
        , Category = ac.wfcategorie
        , AcquisitionGoal = ac.acquisition_goal
	, AppointmentType = 'ContactPerson'
	, [Subject] = NULL
FROM
	[archive].appointmentcustomercontact ac
	LEFT OUTER JOIN [archive].accountmanager am ON ac.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN Dim.ContactPerson cp ON ac.customercontactid = cp.unid
	LEFT OUTER JOIN Dim.Customer cu ON cp.CustomerKey = cu.CustomerKey

UNION

/* Project afspraken toevoegen */
SELECT
	unid = ac.unid
	, OperatorKey = COALESCE(acm.AccountManagerKey, -1)
	, CustomerKey = COALESCE(p.CustomerKey, -1)
	, ContactPersonKey = -1
	, ProjectKey = COALESCE(p.ProjectKey, -1)
	, RequestKey = -1
	, [Status] = ac.[status]
	, AppointmentDate = ac.afspraaktijd
	, AppointmentCreationDate = ac.dataanmk
        , Result = ac.resultaat
        , Category = ac.wfcategorie
        , AcquisitionGoal = ac.acquisition_goal
	, AppointmentType = 'Project'
	, [Subject] = ac.onderwerp
FROM
	[archive].appointmentproject ac
	LEFT OUTER JOIN [archive].accountmanager am ON ac.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN Dim.Project p ON ac.projectid = p.unid

UNION

/* Aanvraag afspraken toevoegen */
SELECT
	unid = apr.unid
	, OperatorKey = COALESCE(acm.AccountManagerKey, -1) 
	, CustomerKey = COALESCE(p.CustomerKey, -1)
	, ContactPersonKey = -1 
	, ProjectKey = COALESCE(r.ProjectKey, -1)
	, RequestKey = COALESCE(r.RequestKey, -1)
	, [Status] = apr.[status]
	, AppointmentDate = apr.afspraaktijd
	, AppointmentCreationDate = apr.dataanmk
        , Result = apr.resultaat
        , Category = apr.wfcategorie
        , AcquisitionGoal = apr.acquisition_goal
	, AppointmentType = 'Request'
	, [Subject] = apr.onderwerp
FROM
	[archive].appointmentrequest apr
	LEFT OUTER JOIN [archive].accountmanager am ON apr.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN [archive].aanvraag a ON apr.requestid = a.unid
	LEFT OUTER JOIN Dim.Request r ON a.unid = r.unid
	LEFT OUTER JOIN Dim.Project p ON r.ProjectKey = p.ProjectKey

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