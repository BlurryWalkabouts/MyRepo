CREATE PROCEDURE [etl].[LoadDimCustomer]
AS
BEGIN

-- Test data: Debitnumber and company size randomized.
-- Select four arbitrary customers that have a project, plus OGD.

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.Customer

;WITH CompanySizes AS
(
SELECT DISTINCT
	CustomerCompanySize
	, RowNum = DENSE_RANK () OVER (ORDER BY CustomerCompanySize)
FROM
	[$(LIFTDW)].Dim.Customer
WHERE 1=1
	AND CustomerCompanySize IS NOT NULL
)

, CompanyList AS
(
SELECT TOP 4 c.CustomerKey
FROM [$(LIFTDW)].Dim.Customer c
INNER JOIN [$(LIFTDW)].Dim.[Project] p ON c.CustomerKey = p.CustomerKey
WHERE c.CustomerKey > -1

UNION

SELECT MAX (c.CustomerKey)
FROM [$(LIFTDW)].Dim.Customer c
INNER JOIN [$(LIFTDW)].Dim.Project p ON c.CustomerKey = p.CustomerKey
WHERE CustomerFullname LIKE '%OGD%'
)

, DataSet AS
(
SELECT
	c.CustomerKey
	, c.AccountManagerKey
	, c.unid
	, c.CustomerFullname
	, c.CustomerPostcode
	, c.CustomerAddress
	, c.CustomerCity
	, c.CustomerCountry
	, c.ServiceDeliveryManager
	, c.CustomerActive
	, Seed = ABS(CHECKSUM(NEWID()) % (SELECT COUNT(*) FROM CompanySizes)) + 1
FROM
	[$(LIFTDW)].Dim.Customer c
	INNER JOIN CompanyList l ON c.CustomerKey = l.CustomerKey
)

INSERT INTO
	Dim.Customer
	(
	CustomerKey
	, AccountManagerKey
	, unid
	, CustomerDebitNumber
	, CustomerFullname
	, CustomerPostcode
	, CustomerAddress
	, CustomerCity
	, CustomerCountry
	, CustomerCompanySize
	, ServiceDeliveryManager
	, CustomerActive
	)
SELECT
	d.CustomerKey
	, d.AccountManagerKey
	, d.unid
	, CustomerDebitNumber = ABS(CHECKSUM(NEWID()) % 3000) + 700
	, d.CustomerFullname
	, d.CustomerPostcode
	, d.CustomerAddress
	, d.CustomerCity
	, d.CustomerCountry
	, s.CustomerCompanySize
	, d.ServiceDeliveryManager
	, d.CustomerActive
FROM
	DataSet d
	LEFT OUTER JOIN CompanySizes s ON d.Seed = s.RowNum

UNION ALL

-- Test customer
SELECT
	CustomerKey = -2
	, AccountManagerKey = -1
	, unid = NEWID()
	, CustomerDebitNumber = ABS(CHECKSUM(NEWID()) % 3000) + 700
	, CustomerFullname = 'Testklant'
	, CustomerPostcode = '1234TE'
	, CustomerAddress = 'Teststraat 17'
	, CustomerCity = 'Testwijk'
	, CustomerCountry = 'Nederland'
	, CustomerCompanySize = (SELECT TOP 1 CustomerCompanySize FROM CompanySizes)
	, ServiceDeliveryManager = NULL
	, CustomerActive = 1

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END