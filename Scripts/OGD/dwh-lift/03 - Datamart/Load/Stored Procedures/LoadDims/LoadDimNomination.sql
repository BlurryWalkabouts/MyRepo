CREATE PROCEDURE [Load].[LoadDimNomination]
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

DELETE FROM Dim.Nomination

DBCC CHECKIDENT ('Dim.Nomination', RESEED, 110000000)

PRINT 'Inserting unknowns into Dim.Nomination'
SET IDENTITY_INSERT Dim.Nomination ON
INSERT INTO
	Dim.Nomination
	(
	NominationKey
	, ProjectKey
	, RequestKey
	, CustomerKey
	, EmployeeKey
	, ActivityGroupKey
	, LedgerKey
	, TaskKey
	, ProductGroup
	, Product
	)
SELECT
	NominationKey = -1
	, ProjectKey = -1
	, RequestKey = -1
	, CustomerKey = -1
	, EmployeeKey = -1
	, ActivityGroupKey = -1
	, LedgerKey = -1
	, TaskKey = -1
	, ProductGroup = '[Unknown]'
	, Product = '[Unknown]'
SET IDENTITY_INSERT Dim.Nomination OFF

PRINT 'Inserting data into Dim.Nomination'
INSERT INTO
	Dim.Nomination
	(
	unid
	, ProjectKey
	, RequestKey
	, CustomerKey
	, EmployeeKey
	, ActivityGroupKey
	, LedgerKey
	, TaskKey
	, RequestNumber
	, NominationName
	, PlanningStartDate
	, PlanningEndDate
	, WorkloadWeekly
	, HourlyRate
	, ChangeDate
	, Internal
	, NominationType
	, [Status]
	, ProductGroup
	, Product
	)

/* Inserting personal nominations */
SELECT
	unid = v.unid
	, ProjectKey = COALESCE(p.ProjectKey, -1) -- Always matches
	, RequestKey = COALESCE(r.RequestKey, -1) -- Always matches
	, CustomerKey = COALESCE(c.CustomerKey, -1) -- Always matches
	, EmployeeKey = COALESCE(e.EmployeeKey, -1) -- Always matches, except for 181 cases (employeeid in source table is NULL in 181 cases)
	, ActivityGroupKey = -1
	, LedgerKey = COALESCE(l.LedgerKey, -1)
	, TaskKey = -1
	, RequestNumber = a.aanvraagnr
	, NominationName = '[Unknown]'
	, PlanningStartDate = CAST(v.startdatum AS date)
	, PlanningEndDate = CAST(v.einddatum AS date)
	, WorkloadWeekly = v.werklast
	, HourlyRate = v.uurprijs
	, ChangeDate = v.datwijzig
	, Internal = v.intern
	, NominationType = 'Personal'
	, [Status] = v.[status]
	, ProductGroup = COALESCE(bh.tekst, '[Unknown]')
	, Product = COALESCE(d.naam, '[Unknown]')
FROM
	[archive].voordracht v
	LEFT OUTER JOIN Dim.Project p ON p.unid = v.projectid
	LEFT OUTER JOIN Dim.Customer c ON c.CustomerKey = p.CustomerKey
	LEFT OUTER JOIN [archive].aanvraag a ON a.unid = v.aanvraagid
	LEFT OUTER JOIN Dim.Employee e ON e.unid = v.employeeid
	LEFT OUTER JOIN Dim.Ledger l ON l.unid = v.grootboekid
	LEFT OUTER JOIN Dim.Request r ON a.unid = r.unid
	LEFT OUTER JOIN [archive].dienst d ON d.unid = v.productid
	LEFT OUTER JOIN [archive].budgethouder bh ON bh.unid = d.budgethouderid
--		AND v.startdatum > e.ContractStartDate AND v.startdatum < e.ContractEndDate -- Disabled these conditions on 17-07-2017; this caused '-1' for ~25% of the cases for the EmployeeKey

UNION

/* Inserting activity group nominations */
SELECT
	unid = agv.unid
	, ProjectKey = COALESCE(p.ProjectKey, -1) -- Always matches
	, RequestKey = COALESCE(r.RequestKey, -1) -- Always matches
	, CustomerKey = COALESCE(c.CustomerKey, -1) -- Always matches
	, EmployeeKey = -1 -- Activity group nominations are not connected to specific employees
	, ActivityGroupKey = ag.ActivityGroupKey
	, LedgerKey = COALESCE(l.LedgerKey, -1)
	, TaskKey = -1
	, RequestNumber = a.aanvraagnr
	, NominationName = ag.ActivityGroupName
	, PlanningStartDate = CAST(agv.startdatum_groep AS date)
	, PlanningEndDate = CAST(agv.einddatum_groep AS date)
	, WorkloadWeekly = agv.totale_werklast
	, HourlyRate = agv.uurprijs
	, ChangeDate = agv.datwijzig
	, Internal = agv.intern
	, NominationType = 'Activity Group'
	, [Status] = agv.[status]
	, ProductGroup = COALESCE(bh.tekst, '[Unknown]')
	, Product = COALESCE(d.naam, '[Unknown]')
FROM
	[archive].activiteitgroep_voordracht agv
	LEFT OUTER JOIN Dim.Project p ON p.unid = agv.projectid
	LEFT OUTER JOIN Dim.Customer c ON c.CustomerKey = p.CustomerKey
	LEFT OUTER JOIN [archive].aanvraag a ON a.unid = agv.aanvraagid
	LEFT OUTER JOIN Dim.Ledger l ON l.unid = agv.grootboekid
	LEFT OUTER JOIN Dim.ActivityGroup ag ON agv.activiteitgroepid = ag.unid
	LEFT OUTER JOIN Dim.Request r ON a.unid = r.unid
	LEFT OUTER JOIN [archive].dienst d ON d.unid = agv.productid
	LEFT OUTER JOIN [archive].budgethouder bh ON bh.unid = d.budgethouderid

UNION

/* Inserting task nominations */
SELECT
	unid = tv.unid
	, ProjectKey = -1 -- Task nominations are internal and not connected to a project
	, RequestKey = -1 -- Task nominations are internal > not connected to a project > no request number
	, CustomerKey = -1 -- Task nominations are internal and not connected to a customer
	, EmployeeKey = COALESCE(e.EmployeeKey, -1) -- Always matches
	, ActivityGroupKey = -1
	, LedgerKey = -1
	, TaskKey = COALESCE(t.TaskKey, -1)
	, RequestNumber = CAST(-1 AS nvarchar(20)) -- Task nominations are internal > not connected to a project > no request number
	, NominationName = t.TaskName
	, PlanningStartDate = CAST(tv.startdatum AS date)
	, PlanningEndDate = CAST(tv.einddatum AS date)
	, WorkloadWeekly = tv.werklast
	, HourlyRate = 0 -- Task nominations do not generate a turnover
	, ChangeDate = tv.datwijzig
	, Internal = 1 -- Task nominations are by definition internal
	, NominationType = 'Task'
	, [Status] = tv.[status]
	, ProductGroup = '[Unknown]'
	, Product = '[Unknown]'
FROM
	[archive].taakvoordracht tv
	LEFT OUTER JOIN Dim.Employee e ON e.unid = tv.employeeid
--		AND tv.startdatum > e.ContractStartDate AND tv.startdatum < e.ContractEndDate -- Disabled these conditions on 17-07-2017; this caused '-1' for ~25% of the cases for the EmployeeKey
	LEFT OUTER JOIN Dim.Task t ON t.unid = tv.taakid

UNION

/* Inserting generic task nominations */
SELECT
	unid = NULL -- Don't exist in LIFT
	, ProjectKey = -1 -- Task nominations are internal and not connected to a project
	, RequestKey = -1 -- Task nominations are internal > not connected to a project > no request number
	, CustomerKey = -1 -- Task nominations are internal and not connected to a customer
	, EmployeeKey = COALESCE(e.EmployeeKey, -1) -- Always matches
	, ActivityGroupKey = -1
	, LedgerKey = -1
	, TaskKey = COALESCE(t.TaskKey, -1)
	, RequestNumber = CAST(-1 AS nvarchar(20)) -- Task nominations are internal > not connected to a project > no request number
	, NominationName = '[Unknown]'
	, PlanningStartDate = e.JoinDate
	, PlanningEndDate = CASE WHEN t.TaskEndDate < e.ContractEndDate THEN t.TaskEndDate ELSE e.ContractEndDate END
	, WorkloadWeekly = 0
	, HourlyRate = 0 -- Task nominations do not generate a turnover
	, ChangeDate = NULL
	, Internal = 1 -- Task nominations are by definition internal
	, NominationType = 'Public Task'
	, [Status] = t.TaskStatus
	, ProductGroup = '[Unknown]'
	, Product = '[Unknown]'
FROM
	Dim.Employee e
	CROSS APPLY Dim.Task t
WHERE 1=1
	AND t.IsPublic = 1
--	AND t.TaskStatus = 1
	AND e.JoinDate < GETUTCDATE()
	AND e.ContractEndDate IS NOT NULL

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