CREATE PROCEDURE [etl].[LoadDimNomination]
AS
BEGIN

-- Test data: All dates randomized; hourlyrate randomized (20 - 110), workloadweekly randomized (0 - 100).
-- For each project in our list, select the top two employees.

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.Nomination

;WITH DistinctEmployees AS
(
SELECT DISTINCT
	ProjectKey
	, EmployeeKey
FROM
	[$(LIFTDW)].Dim.Nomination
)

, EmployeeList AS
(
SELECT
	e.ProjectKey
	, e.EmployeeKey
	, RowNum = ROW_NUMBER() OVER (PARTITION BY e.ProjectKey ORDER BY e.EmployeeKey DESC)
FROM
	DistinctEmployees e
	INNER JOIN Dim.Project p ON e.ProjectKey = p.ProjectKey
)

INSERT INTO
	Dim.Nomination
	(
	NominationKey
	, unid
	, ProjectKey
	, CustomerKey
	, EmployeeKey
	, RequestNumber
	, PlanningStartDate
	, PlanningEndDate
	, WorkloadWeekly
	, HourlyRate
	, ChangeDate
	, Internal
	, NominationType
	, [Status]
	)
SELECT
	n.NominationKey
	, n.unid
	, n.ProjectKey
	, n.CustomerKey
	, n.EmployeeKey
	, n.RequestNumber
	, PlanningStartDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, PlanningEndDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, WorkloadWeekly = ABS(CHECKSUM(NEWID()) % 100)
	, HourlyRate = ABS(CHECKSUM(NEWID()) % 90) + 20
	, ChangeDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, n.Internal
	, n.NominationType
	, n.[Status]
FROM
	[$(LIFTDW)].Dim.Nomination n
	INNER JOIN EmployeeList e ON n.EmployeeKey = e.EmployeeKey AND e.RowNum <= 2

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END