CREATE PROCEDURE [Load].[LoadFactContactNote]
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

DELETE FROM Fact.ContactNote

PRINT 'Inserting data into Fact.ContactNote'

INSERT INTO
	Fact.ContactNote
	(
		ContactNoteSourceId
		, ContactNoteCustomerKey
		, ContactNoteCustomerName
		, ContactNoteContactPersonKey 
		, ContactNoteContactPersonName
		, ContactNoteCreatedByEmployeeKey
		, ContactNoteCreatedByEmployeeName
		, ContactNoteCreatedByTeam
		, ContactNoteModifiedByEmployeeKey
		, ContactNoteModifiedByEmployeeName
		, ContactNoteModifiedByTeam
		, ContactNoteBusinessUnitKey
		, ContactNoteBusinessUnitName
		, ContactNoteAcquisitiongoal
		, ContactNoteDateTimeCreated
		, ContactNoteDateCreated
		, ContactNoteTimeCreated
		, ContactNoteDateTimeModified
		, ContactNoteDateModified
		, ContactNoteTimeModified
		, ContactNoteType
		, ContactNoteCategory
		, ContactNoteContactLevel
	)

/* Begin met ophalen van gespreksnotities */
SELECT
	ContactNoteSourceId = cnc.unid
	, ContactNoteCustomerKey = COALESCE(cu.CustomerKey, -1)
	, ContactNoteCustomerName = COALESCE(cu.CustomerFullname, '[unknown]')
	, ContactNoteContactPersonKey = COALESCE(cp.ContactPersonKey, -1)
	, ContactNoteContactPersonName = COALESCE(cp.ContactPerson, '[unknown]')
	, ContactNoteCreatedByEmployeeKey = COALESCE(e1.EmployeeKey, -1)
	, ContactNoteCreatedByEmployeeName = COALESCE(e1.FullName, '[unknown]')
	, ContactNoteCreatedByTeam = '[unknown]'
	, ContactNoteModifiedByEmployeeKey = COALESCE(e2.EmployeeKey, -1)
	, ContactNoteModifiedByEmployeeName = COALESCE(e2.FullName, '[unknown]')
	, ContactNoteModifiedByTeam = '[unknown]'
	, ContactNoteBusinessUnitKey = -1
	, ContactNoteBusinessUnitName = '[unknown]'
	, ContactNoteAcquisitiongoal = COALESCE(cnc.acquisition_goal, '[unknown]')
	, ContactNoteDateTimeCreated = COALESCE(cnc.dataanmk, '99991231 23:59:59')
	, ContactNoteDateCreated = CAST(COALESCE(cnc.dataanmk, '99991231') AS DATE)
	, ContactNoteTimeCreated = CAST(COALESCE(cnc.dataanmk, '23:59:59') AS TIME)
	, ContactNoteDateTimeModified = COALESCE(cnc.datwijzig, '99991231 23:59:59')
	, ContactNoteDateModified = CAST(COALESCE(cnc.datwijzig, '99991231') AS DATE)
	, ContactNoteTimeModified = CAST(COALESCE(cnc.datwijzig, '23:59:59') AS TIME)
	, ContactNoteType = COALESCE(cnc.[type], '[unknown]')
	, ContactNoteCategory = COALESCE(cnc.categorie, '[unknown]')
	, ContactNoteContactLevel = 'Customer'
FROM
	[archive].contactnotecustomer cnc
	LEFT OUTER JOIN [archive].gebruiker g1 ON cnc.uidaanmk = g1.unid
	LEFT OUTER JOIN [archive].gebruiker g2 ON cnc.uidwijzig = g2.unid
	LEFT OUTER JOIN Dim.Employee e1 ON g1.employeeid = e1.unid
	LEFT OUTER JOIN Dim.Employee e2 ON g2.employeeid = e2.unid
	LEFT OUTER JOIN Dim.Customer cu ON cnc.customerid = cu.unid
	LEFT OUTER JOIN Dim.ContactPerson cp ON cnc.customercontactid = cp.unid

UNION ALL

SELECT
	ContactNoteUnid = cncc.unid
	, ContactNoteCustomerKey = COALESCE(cu.CustomerKey, -1)
	, ContactNoteCustomerName = COALESCE(cu.CustomerFullname, '[unknown]')
	, ContactNoteContactPersonKey = COALESCE(cp.ContactPersonKey, -1)
	, ContactNoteContactPersonName = COALESCE(cp.ContactPerson, '[unknown]')
	, ContactNoteCreatedByEmployeeKey = COALESCE(e1.EmployeeKey, -1)
	, ContactNoteCreatedByEmployeeName = COALESCE(e1.FullName, '[unknown]')
	, ContactNoteCreatedByTeam = '[unknown]'
	, ContactNoteModifiedByEmployeeKey = COALESCE(e2.EmployeeKey, -1)
	, ContactNoteModifiedByEmployeeName = COALESCE(e2.FullName, '[unknown]')
	, ContactNoteModifiedByTeam = '[unknown]'
	, ContactNoteBusinessUnitKey = -1
	, ContactNoteBusinessUnitName = '[unknown]'
	, ContactNoteAcquisitiongoal = COALESCE(cncc.acquisition_goal, '[unknown]')
	, ContactNoteDateTimeCreated = CAST(COALESCE(cncc.dataanmk, '99991231') AS DATE)
	, ContactNoteDateCreated = CAST(COALESCE(cncc.dataanmk, '99991231') AS DATE)
	, ContactNoteTimeCreated = CAST(COALESCE(cncc.dataanmk, '23:59:59') AS TIME)
	, ContactNoteDateTimeModified = COALESCE(cncc.datwijzig, '99991231 23:59:59')
	, ContactNoteDateModified = CAST(COALESCE(cncc.datwijzig, '99991231') AS DATE)
	, ContactNoteTimeModified = CAST(COALESCE(cncc.datwijzig, '23:59:59') AS TIME)
	, ContactNoteType = COALESCE(cncc.[type], '[unknown]')
	, ContactNoteCategory = COALESCE(cncc.categorie, '[unknown]')
	, ContactNoteContactLevel = 'Contact Person'
FROM
	[archive].contactnotecustomercontact cncc
	LEFT OUTER JOIN [archive].gebruiker g1 ON cncc.uidaanmk = g1.unid
	LEFT OUTER JOIN [archive].gebruiker g2 ON cncc.uidwijzig = g2.unid
	LEFT OUTER JOIN Dim.Employee e1 ON g1.employeeid = e1.unid
	LEFT OUTER JOIN Dim.Employee e2 ON g2.employeeid = e2.unid
	LEFT OUTER JOIN Dim.Customer cu ON cncc.customerid = cu.unid
	LEFT OUTER JOIN Dim.ContactPerson cp ON cncc.customercontactid = cp.unid

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