CREATE PROCEDURE [etl].[LoadDimProject]
AS
BEGIN

-- Test data: All dates set to a random value between 2010 and 2019 inclusive.
-- Select one projectsfor each customer from our test list

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.[Project]

;WITH ProjectList AS
(
SELECT
	c.CustomerKey
	, ProjectKey = MAX(ProjectKey)
FROM
	Dim.Customer c
	INNER JOIN [$(LIFTDW)].Dim.Project p ON c.CustomerKey = p.CustomerKey
GROUP BY
	c.CustomerKey
)

INSERT INTO
	Dim.Project
	(
	ProjectKey
	, unid
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
	)
SELECT
	p.ProjectKey
	, p.unid
	, p.ProjectNumber
	, p.ProjectName
	, p.CustomerKey
	, p.OperatorKey
	, p.ProductGroup
	, p.Product
	, p.ProjectGroupNumber
	, p.ProjectGroupName
	, p.ProjectStatus
	, ProjectStartDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectEndDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectCreationDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectChangeDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectAcceptDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectArchiveDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, p.Office
	, p.SalesTarget
	, p.ProjectPrice
FROM
	[$(LIFTDW)].Dim.Project p
	INNER JOIN ProjectList l ON p.ProjectKey = l.ProjectKey

UNION ALL

-- Testproject
SELECT
	-2
	, unid = NEWID()
	, ProjectNumber = '42'
	, ProjectName = 'Test Project'
	, CustomerKey = -2
	, OperatorKey = -2
	, ProductGroup = 'Testgroep'
	, Product = 'Testproduct'
	, ProjectGroupNumber = '42'
	, ProjectGroupName = 'Testprojectgroep'
	, ProjectStatus = 1
	, ProjectStartDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectEndDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectCreationDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectChangeDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectAcceptDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ProjectArchiveDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, Office = 'Amsterdam'
	, SalesTarget = 1042.00
	, ProjectPrice = 10042.00

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END