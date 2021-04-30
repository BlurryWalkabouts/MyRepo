CREATE PROCEDURE [etl].[LoadDimEmployee]
AS
BEGIN

-- Test data: Contracthours and ExternalRate randomized (usually NULL)
-- Select only employees that have a nomination in our test set

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.Employee

-- Testmedewerker x3
;WITH TestWerknemer AS
(
	SELECT ID = -2, [Name] = 'Jan'
	UNION SELECT ID = -3, [Name] = 'Bob'
	UNION SELECT ID = -4, [Name] = 'Henk'
)

INSERT INTO
	Dim.Employee
	(
	EmployeeKey
	, unid
	, EmployeeNumber
	, LastName
	, GivenName
	, Prefixes
	, Initials
	, BirthYear
	, EmailAddress
	, PostalCode
	, City
	, PhoneNumber
	, BusinessTeam
	, HRRepresentative
	, ContractStartDate
	, ContractEndDate
	, ContractType
	, ContractHours
	, HasActiveContract
	, ExternalRate
	, OwnsCar
	, HasDriversLicense
	)
SELECT
	EmployeeKey
	, unid
	, EmployeeNumber
	, LastName
	, GivenName
	, Prefixes
	, Initials
	, BirthYear
	, EmailAddress
	, PostalCode
	, City
	, PhoneNumber
	, BusinessTeam
	, HRRepresentative
	, ContractStartDate
	, ContractEndDate
	, ContractType
	, ContractHours = CASE
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.99 THEN 32
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.80 THEN 40
			ELSE NULL
		END
	, HasActiveContract
	, ExternalRate = CASE
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.99 THEN 45.0
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.99 THEN 37.5
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.99 THEN 42.5
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.83 THEN  0.0
			ELSE NULL
		END
	, OwnsCar
	, HasDriversLicense
FROM
	[$(LIFTDW)].Dim.Employee
WHERE 1=1
	AND EmployeeKey IN (SELECT EmployeeKey FROM Dim.Nomination)

UNION ALL

SELECT
	ID
	, unid = NEWID()
	, EmployeeNumber = ID
	, LastName = 'Test'
	, GivenName = [Name]
	, Prefixes = ''
	, Initials = LEFT([Name], 1) + '.'
	, BirthYear = CAST(RAND(CAST(NEWID() AS varbinary)) * 30 + 1970 AS int)
	, EmailAddress = LOWER([Name]) + '.test@ogd.nl'
	, PostalCode = '1234'
	, City = 'Testdam'
	, PhoneNumber = '06' + SUBSTRING(CAST(RAND(CAST(NEWID() AS varbinary)) AS varchar(12)), 3, 9)
	, BusinessTeam = ''
	, HRRepresentative = 'Flip Test'
	, ContractStartDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ContractEndDate = NULL
	, ContractType = 'Testcontract'
	, ContractHours = 40
	, HasActiveContract = 1
	, ExternalRate = CASE
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.99 THEN 45.0
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.99 THEN 37.5
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.99 THEN 42.5
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.83 THEN  0.0
			ELSE NULL
		END
	, OwnsCar = CASE RAND(CAST(NEWID() AS varbinary)) WHEN 0.5 THEN 1 ELSE 0 END
	, HasDriversLicense = CASE RAND(CAST(NEWID() AS varbinary)) WHEN 0.5 THEN 1 ELSE 0 END
FROM
	TestWerknemer

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END