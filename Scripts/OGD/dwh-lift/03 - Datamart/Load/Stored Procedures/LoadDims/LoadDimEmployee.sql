CREATE PROCEDURE [Load].[LoadDimEmployee]
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

DELETE FROM Dim.Employee

DBCC CHECKIDENT ('Dim.Employee', RESEED, 20000000)

PRINT 'Inserting unknowns into Dim.Employee'
SET IDENTITY_INSERT Dim.Employee ON
INSERT INTO
	Dim.Employee
	(
	EmployeeKey
	, EmployeeNumber
	, LastName
	, GivenName
	, Prefixes
	, ContractType
	, HasActiveContract
	, [Function]
        , Team
	, HRRepresentativeKey
	, HRRepresentative
	, ManagerKey		
	, Manager
	, JoinDate
	, EmployeeOffice
	)
SELECT
	EmployeeKey = -1
	, EmployeeNumber = ''
	, LastName = '[unknown]'
	, GivenName = '[unknown]'
	, Prefixes = ''
	, ContractType = '[unknown]'
	, HasActiveContract = 0
	, [Function] = '[unknown]'
        , Team = '[unknown]'
	, HRRepresentativeKey = -1
	, HRRepresentative = '[unknown]'
	, ManagerKey = -1		
	, Manager = '[unknown]'
	, JoinDate = NULL
	, EmployeeOffice = '[unknown]'
SET IDENTITY_INSERT Dim.Employee OFF

PRINT 'Inserting data into Dim.Employee'
INSERT INTO
	Dim.Employee
	(
	unid
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
	, BusinessUnit
	, [Function]
        , Team
	, ManagerKey
	, Manager
	, HRRepresentativeKey	
	, HRRepresentative
	, JoinDate
	, ContractStartDate
	, ContractEndDate
	, ContractType
	, ContractHours
	, HasActiveContract
	, NextAppointment
	, ExternalRate
	, OwnsCar
	, HasDriversLicense
	, [Availability]
	, EmployeeOffice
	)
SELECT
	unid = w.unid
	, EmployeeNumber = w.persnr
	, LastName = LTRIM(RTRIM(w.anaam))
	, GivenName = LTRIM(RTRIM(w.rnaam))
	, Prefixes = LTRIM(RTRIM(w.tussen))
	, Initials = LTRIM(RTRIM(w.inits))
	, BirthYear = w.geboortejaar
	, EmailAddress = CASE WHEN w.email LIKE '%ogd.nl' THEN w.email ELSE NULL END -- Alleen OGD-adressen weergeven (geen privé-adressen) ivm privacy
	, PostalCode = LEFT(w.postcode1,4) -- Alleen de cijfers van de postcode weergeven ivm privacy
	, City = w.plaats1
	, PhoneNumber = CASE WHEN w.tel1 LIKE '088%' THEN w.tel1 ELSE NULL END -- Alleen OGD-telefoonnummers weergeven (geen privénummers) ivm privacy
	, BusinessTeam = w.business_unit
	, BusinessUnit = w.business_unit
	, [Function] = w.functie
        , Team = w.extra_team
	, ManagerKey = NULL
	, Manager = w.Leidinggevende
	, HRRepresentativeKey = NULL
	, HRRepresentative = w.HR_ContactPersoon
	, JoinDate = w.datumindienst
	, ContractStartDate = wc.startdatum
	, ContractEndDate = CASE WHEN wc.startdatum IS NULL THEN NULL ELSE COALESCE(wc.einddatum, '9999-12-31') END
	, ContractType = wc.contractsoort
	, ContractHours = 40 * wc.procent / 100
	, HasActiveContract = CASE WHEN GETDATE() BETWEEN wc.startdatum AND COALESCE(wc.einddatum, '9999-12-31') THEN 1 ELSE 0 END
	, NextAppointment = CASE
			WHEN GETDATE() BETWEEN wc.startdatum AND COALESCE(wc.einddatum, '9999-12-31')
				THEN CONCAT(COALESCE(w.nextappointment_jaar,'????'), '-', COALESCE(LEFT(nextappointment_maand,2),'??'))
			ELSE ''
		END
	, ExternalRate = wc.uurtarief
	, OwnsCar = w.[auto]
	, HasDriversLicense = w.rijbewijs
	, [Availability] = w.stdbeschikbaarheid
	, EmployeeOffice = COALESCE(w.vestiging, '[unknown]')
FROM
    [archive].werknemer w
	OUTER APPLY ( -- Vind het laatste contract dat niet in de toekomst ingaat
		SELECT TOP 1 startdatum, einddatum, contractsoort, procent, uurtarief
		FROM [archive].wcontract wc
		WHERE w.unid = wc.werknemerid AND wc.startdatum <= GETDATE()
		ORDER BY wc.startdatum DESC) wc
WHERE 1=1
	AND ABS([status]) IN (3,4) -- 1 = sollicitant, 2 = potentiële werknemer, 3 = werknemer, 4 = inhuurkracht

UPDATE
	e1
SET
	e1.HRRepresentativeKey = e2.EmployeeKey
	, e1.ManagerKey = e3.EmployeeKey
FROM
	Dim.Employee e1
	LEFT OUTER JOIN Dim.Employee e2 ON e1.HRRepresentative = e2.FullName
	LEFT OUTER JOIN Dim.Employee e3 ON e1.Manager = e3.FullName

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