CREATE PROCEDURE [liftetl].[LoadLiftDW]
AS

BEGIN

DECLARE @dbName nvarchar(64) = '[$(LIFTDW)]'

/********************************************************************************
Drop foreign keys
********************************************************************************/

PRINT 'Drop foreign keys'
EXEC shared.DisableForeignKeys @dbName

/********************************************************************************
Truncate tables
********************************************************************************/
PRINT 'Truncate Dim and Fact tables'

DECLARE @SQLString nvarchar(max) = STUFF((
	SELECT 'DELETE FROM [$(LIFTDW)].[' + TABLE_SCHEMA + '].[' + TABLE_NAME + '];' + CHAR(10)
	FROM [$(LIFTDW)].INFORMATION_SCHEMA.TABLES
	WHERE 1=1
		AND TABLE_TYPE = 'BASE TABLE'
		AND TABLE_SCHEMA IN ('Dim','Fact','log')
		AND TABLE_NAME <> 'Date'
	FOR XML PATH('')), 1, 0, '')

EXEC (@SQLString)

DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Customer', RESEED, 10000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Employee', RESEED, 20000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.AccountManager', RESEED, 30000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Project', RESEED, 40000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.HourType', RESEED, 50000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Service', RESEED, 60000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.EmployeeContract', RESEED, 70000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Course', RESEED, 80000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Diploma', RESEED, 90000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Ledger', RESEED, 100000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Nomination', RESEED, 110000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Task', RESEED, 120000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.Request', RESEED, 130000000)
DBCC CHECKIDENT ('[$(LIFTDW)].Dim.ContactPerson', RESEED, 140000000)

/********************************************************************************
Insert dates into Dim.Date
********************************************************************************/

PRINT 'Inserting dates into Dim.Date'
EXEC shared.LoadDimDate @dbName

/********************************************************************************
Insert default data into Dim and Fact tables
********************************************************************************/

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.AccountManager'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.AccountManager ON
INSERT INTO
	[$(LIFTDW)].Dim.AccountManager
	(
	AccountManagerKey
	, AccountManagerName
	)
SELECT
	AccountManagerKey = -1
	, AccountManagerName = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.AccountManager OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.HourType'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.HourType ON
INSERT INTO
	[$(LIFTDW)].Dim.HourType
	(
	HourTypeKey
	, [Percentage]
	, Billable
	, RateName
	)
SELECT
	HourTypeKey = -1
	, [Percentage] = NULL
	, Billable = NULL
	, RateName = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.HourType OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Service'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.[Service] ON
INSERT INTO
	[$(LIFTDW)].Dim.[Service]
	(
	ServiceKey
	, ProductNomination
	)
SELECT
	ServiceKey = -1
	, ProductNomination = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.[Service] OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Customer'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Customer ON
INSERT INTO
	[$(LIFTDW)].Dim.Customer
	(
	CustomerKey
	, AccountManagerKey
	, CustomerDebitNumber
	, CustomerFullname
	, CustomerPostcode
	, CustomerAddress
	, CustomerCity
	, CustomerCountry
	, CustomerCompanySize
	)
SELECT
	CustomerKey = -1
	, AccountManagerKey = -1
	, CustomerDebitNumber = '[unknown]'
	, CustomerFullname = '[unknown]'
	, CustomerPostcode = '[unknown]'
	, CustomerAddress = '[unknown]'
	, CustomerCity = '[unknown]'
	, CustomerCountry = '[unknown]'
	, CustomerCompanySize = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Customer OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Employee'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Employee ON
INSERT INTO
	[$(LIFTDW)].Dim.Employee
	(
	EmployeeKey
	, EmployeeNumber
	, LastName
	, GivenName
	, Prefixes
	, ContractType
	, HasActiveContract
	, [Function]
	, HRRepresentativeKey
	, HRRepresentative
	, ManagerKey		
	, Manager
	, JoinDate	
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
	, HRRepresentativeKey = -1
	, HRRepresentative = '[unknown]'
	, ManagerKey = -1		
	, Manager = '[unknown]'
	, JoinDate = NULL
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Employee OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Ledger'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Ledger ON
INSERT INTO
	[$(LIFTDW)].Dim.Ledger
	(
	LedgerKey
	, [Text]
	, [Description]
	)
SELECT
	LedgerKey = -1
	, [Text] = '[unknown]'
	, [Description] = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Ledger OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Project'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Project ON
INSERT INTO
	[$(LIFTDW)].Dim.Project
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
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Project OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.ContactPerson'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.ContactPerson ON
INSERT INTO
	[$(LIFTDW)].Dim.ContactPerson
	(
	ContactPersonKey
	, CustomerKey
	, Jobtitle
	, Department
	, Responsibility
	, Gender
	, [Role]
	)
SELECT
	ContactPersonKey = -1
	, CustomerKey = -1
	, Jobtitle = '[unknown]'
	, Department = '[unknown]'
	, Responsibility = '[unknown]'
	, Gender = '[unknown]'
	, [Role] = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.ContactPerson OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Task'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Task ON
INSERT INTO
	[$(LIFTDW)].Dim.Task
	(
	TaskKey
	, TaskNumber
	, TaskName
	)
SELECT
	TaskKey = -1
	, TaskNumber = '[unknown]'
	, TaskName = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Task OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Nomination'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Nomination ON
INSERT INTO
	[$(LIFTDW)].Dim.Nomination
	(
	NominationKey
	, ProjectKey
	, CustomerKey
	, EmployeeKey
	, LedgerKey
	, TaskKey
	)
SELECT
	NominationKey = -1
	, ProjectKey = -1
	, CustomerKey = -1
	, EmployeeKey = -1
	, LedgerKey = -1
	, TaskKey = -1
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Nomination OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.EmployeeContract'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.EmployeeContract ON
INSERT INTO
	[$(LIFTDW)].Dim.EmployeeContract
	(
	EmployeeContractKey
	, EmployeeKey
	, ContractCreationDate
	, ContractChangeDate
	, ContractStatus
	, ContractType
	, [Percentage]
	, ContractStartDate
	, ContractEndDate
	, SuggestedHourlyRate
	)
SELECT
	EmployeeContractKey = -1
	, EmployeeKey = -1
	, ContractCreationDate = '99991231'
	, ContractChangeDate = '99991231'
	, ContractStatus = 0
	, ContractType = '[unknown]'
	, [Percentage] = -1
	, ContractStartDate = '99991231'
	, ContractEndDate = '99991231'
	, SuggestedHourlyRate = -1
SET IDENTITY_INSERT [$(LIFTDW)].Dim.EmployeeContract OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Course'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Course ON
INSERT INTO
	[$(LIFTDW)].Dim.Course
	(
	CourseKey
	, EmployeeKey
	, [Provider]
	, CourseName
	, CourseDate
	, CourseEndDate
	, CourseDuration
	, DiplomaObtained
	)
SELECT
	CourseKey = -1
	, EmployeeKey = -1
	, [Provider] = '[unknown]'
	, CourseName = '[unknown]'
	, CourseDate = '99991231'
	, CourseEndDate = '99991231'
	, CourseDuration = -1
	, DiplomaObtained = 0
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Course OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Diploma'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Diploma ON
INSERT INTO
	[$(LIFTDW)].Dim.Diploma
	(
	DiplomaKey
	, Diploma
	)
SELECT
	DiplomaKey = -1
	, Diploma = '[unknown]'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Diploma OFF

PRINT 'Inserting unknowns into [$(LIFTDW)].Dim.Request'
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Request ON
INSERT INTO
	[$(LIFTDW)].Dim.Request
	(
	RequestKey
	, ProjectKey
	, RequestNumber
	, RequestStatus
	, SalesChannel
	, RequestSalesTarget
	, SuccessChance
	)
SELECT
	RequestKey = -1
	, ProjectKey = -1
	, RequestNumber = '[unknown]'
	, RequestStatus = -1
	, SalesChannel = '[unknown]'
	, RequestSalesTarget = -1
	, SuccessChance = -1
SET IDENTITY_INSERT [$(LIFTDW)].Dim.Request OFF

/********************************************************************************
Insert data into Dim and Fact tables
********************************************************************************/

PRINT 'Inserting data into [$(LIFTDW)].Dim.AccountManager'
INSERT INTO
	[$(LIFTDW)].Dim.AccountManager
	(
	unid
	, AccountManagerName
	, Archive
	, [Status]
	, CreationDate
	, ChangeDate
	)
SELECT
	am.unid
	, g.naam
	, am.archief
	, g.[status]
	, g.dataanmk
	, g.datwijzig
FROM
	[$(LIFT_Archive)].dbo.accountmanager am
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.gebruiker g ON am.gebruikerid = g.unid

PRINT 'Inserting data into [$(LIFTDW)].Dim.HourType'
INSERT INTO
	[$(LIFTDW)].Dim.HourType
	(
	[Percentage]
	, Billable
	, RateName
	)
SELECT DISTINCT
	[Percentage] = procent
	, Billable = declarabel
	, RateName = tariefnaam
FROM
	[$(LIFT_Archive)].dbo.uurtype

PRINT 'Inserting data into [$(LIFTDW)].Dim.Service'
INSERT INTO
	[$(LIFTDW)].Dim.[Service]
	(
	ProductNomination
	)
SELECT DISTINCT
	ProductNomination = naam
FROM
	[$(LIFT_Archive)].dbo.dienst

PRINT 'Inserting data into [$(LIFTDW)].Dim.Customer'
INSERT INTO
	[$(LIFTDW)].Dim.Customer
	(
	unid
	, CustomerDebitNumber
	, CustomerFullname
	, AccountManagerKey
	, CustomerPostcode
	, CustomerAddress
	, CustomerCity
	, CustomerRegion
	, CustomerCountry
	, CustomerCompanySize
	, VATNumber
	, CoCNumber
	, CustomerStatus
	)
SELECT
	unid = k.unid
	, CustomerDebitNumber = k.debnr
	, CustomerFullname = k.bedrijf
	, AccountManagerKey = COALESCE(am.AccountManagerKey, -1)
	, CustomerPostcode = k.postcode1
	, CustomerAddress = COALESCE(k.straat1 + ' ' + k.nummer1, k.straat1, '[unknown]')
	, CustomerCity = k.plaats1
	, CustomerRegion = COALESCE(r.tekst, '[unknown]')
	, CustomerCountry = l.landnaam
	, CustomerCompanySize = bg.tekst
	, VATNumber = k.btwnr
	, CoCNumber = k.kvknr
	, CustomerStatus = k.[status]
FROM
	[$(LIFT_Archive)].dbo.klant k
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.regio r ON k.regioid = r.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.land l ON k.land1id = l.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.bedrijfgrootte bg ON k.grootteid = bg.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.AccountManager am ON am.unid = k.behandelaarid

PRINT 'Inserting data into [$(LIFTDW)].Dim.Employee'
INSERT INTO
	[$(LIFTDW)].Dim.Employee
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
	, [Function]
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
	)
SELECT
	unid = w.unid
	, EmployeeNumber = w.persnr
	, LastName = LTRIM(RTRIM(w.anaam))
	, GivenName = LTRIM(RTRIM(w.rnaam))
	, Prefixes = LTRIM(RTRIM(w.tussen))
	, Initials = LTRIM(RTRIM(w.inits))
	, BirthYear = YEAR(w.geboren)
	, EmailAddress = CASE WHEN w.email LIKE '%ogd.nl' THEN w.email ELSE NULL END -- Alleen OGD-adressen weergeven (geen privé-adressen) ivm privacy
	, PostalCode = LEFT(w.postcode1,4) -- Alleen de cijfers van de postcode weergeven ivm privacy
	, City = w.plaats1
	, PhoneNumber = CASE WHEN w.tel1 LIKE '088%' THEN w.tel1 ELSE NULL END -- Alleen OGD-telefoonnummers weergeven (geen privénummers) ivm privacy
	, BusinessTeam = bu.tekst
	, [Function] = fn.tekst
	, ManagerKey = NULL
	, Manager = mn.tekst
	, HRRepresentativeKey = NULL
	, HRRepresentative = po.tekst
	, JoinDate = w.datumindienst
	, ContractStartDate = wc.startdatum
	, ContractEndDate = CASE WHEN wc.startdatum IS NULL THEN NULL ELSE COALESCE(wc.einddatum, '9999-12-31') END
	, ContractType = cs.tekst
	, ContractHours = 40 * wc.procent / 100
	, HasActiveContract = CASE WHEN GETDATE() BETWEEN wc.startdatum AND COALESCE(wc.einddatum, '9999-12-31') THEN 1 ELSE 0 END
	, NextAppointment = CASE
			WHEN GETDATE() BETWEEN wc.startdatum AND COALESCE(wc.einddatum, '9999-12-31')
				THEN CONCAT(COALESCE(v1.tekst,'????'), '-', COALESCE(LEFT(v2.tekst,2),'??'))
			ELSE ''
		END
	, ExternalRate = wc.uurtarief
	, OwnsCar = w.[auto]
	, HasDriversLicense = w.rijbewijs
FROM
	[$(LIFT_Archive)].dbo.werknemer w
	OUTER APPLY ( -- Vind het laatste contract dat niet in de toekomst ingaat
		SELECT TOP 1 startdatum, einddatum, contractsoortid, procent, uurtarief
		FROM [$(LIFT_Archive)].dbo.wcontract wc
		WHERE w.unid = wc.werknemerid AND wc.startdatum <= GETDATE()
		ORDER BY wc.startdatum DESC) wc
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.contractsoort cs ON cs.unid = wc.contractsoortid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vrijopzoek po ON w.extraopz6 = po.unid AND po.kaartcode = 'EXTRAOPZ6WER' -- PO'er
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vrijopzoek bu ON w.exveld004 = bu.unid AND bu.kaartcode = 'TBL01EXVELD004' -- Business Team
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vrijopzoek mn ON w.exveld003 = mn.unid AND mn.kaartcode = 'TBL01EXVELD003' -- Manager
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vrijopzoek fn ON w.exveld005 = fn.unid AND fn.kaartcode = 'TBL01EXVELD005' -- Functie
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vrijopzoek v1 ON w.exveld002 = v1.unid AND v1.kaartcode = 'TBL01EXVELD002' -- Jaartal volgende gesprek
	-- Onderstaand opzoekveld is in eerste instantie voor andere doeleinden gebruikt, vandaar dat gearchiveerde waarden eruit worden gefilterd
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vrijopzoek v2 ON w.extraopz5 = v2.unid AND v2.kaartcode = 'EXTRAOPZ5WER' AND v2.archief = 1 -- Maand volgende gesprek
WHERE 1=1
	AND ABS([status]) IN (3,4) -- 1 = sollicitant, 2 = potentiële werknemer, 3 = werknemer, 4 = inhuurkracht

UPDATE
	e1
SET
	e1.HRRepresentativeKey = e2.EmployeeKey
	, e1.ManagerKey = e3.EmployeeKey
FROM
	[$(LIFTDW)].Dim.Employee e1
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e2 ON e1.HRRepresentative = e2.FullName
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e3 ON e1.Manager = e3.FullName

PRINT 'Inserting data into [$(LIFTDW)].Dim.Ledger'
INSERT INTO
	[$(LIFTDW)].Dim.Ledger
	(
	unid
	, [Text]
	, [Description]
	)
SELECT
	unid = unid
	, [Text] = tekst
	, [Description] = omschrijving
FROM
	[$(LIFT_Archive)].dbo.grootboekrekening

PRINT 'Inserting data into [$(LIFTDW)].Dim.Project'
INSERT INTO
	[$(LIFTDW)].Dim.Project
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
	, Office = v.tekst
	, SalesTarget = p.sales_target
	, ProjectPrice = p.fprojectprijs
FROM
	[$(LIFT_Archive)].dbo.project p
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vestiging v ON v.unid = p.vestigingid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.projectgroep pg ON p.projectgroepid = pg.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Customer c ON c.unid = pg.klantid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.behandelaar b ON b.unid = p.behandeldid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.gebruiker g ON g.unid = b.gebruikerid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.werknemer w ON w.unid = g.employeeid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = w.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.budgethouder bh ON bh.unid = p.productgroepid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.dienst d ON d.unid = p.productid

PRINT 'Inserting data into [$(LIFTDW)].Dim.ContactPerson'
INSERT INTO
	[$(LIFTDW)].[Dim].[ContactPerson]
	(
	unid
	, CustomerKey
	, ContactPerson
	, Jobtitle
	, Telephone_1
	, Telephone_2
	, Mail
	, Department
	, Responsibility
	, Gender
	, LinkedIN
	, #
	, [Role]
	)
SELECT
	unid = cp.unid
	, CustomerKey = COALESCE(c.CustomerKey, -1)
	, ContactPerson = LTRIM(RTRIM(CONCAT(RTRIM(cp.rnaam), ' ', LTRIM(CONCAT(RTRIM(cp.tvoegsel), ' ', LTRIM(cp.anaam))))))
	, [Jobtitle] = cp.functie
	, Telephone_1 = cp.tel1
	, Telephone_2 = cp.tel2
	, Email = cp.email
	, Department = cp.afdeling
	, Responsibility = v.tekst
	, Gender = CASE WHEN cp.geslacht = 1 THEN 'Male' WHEN cp.geslacht = 2 THEN 'Female' ELSE NULL END
	, LinkedIN = COALESCE(cp.linkedin, cp.exveld002, '[unknown]')
	, # = ROW_NUMBER() OVER(PARTITION BY cp.klantid ORDER BY k.bedrijf)
	, [Role] = r.tekst
FROM
	[$(LIFT_Archive)].dbo.contactpersoon cp
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Customer c ON c.unid = cp.klantid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.verantwoording v ON v.unid = cp.verantwoordingid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.klant k ON k.unid = cp.klantid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.rol r ON r.unid = cp.rolid
WHERE 1=1
	AND cp.[status] = 1 -- Active contactpersons

PRINT 'Inserting data into [$(LIFTDW)].Dim.Task'
INSERT INTO
	[$(LIFTDW)].Dim.Task
	(
	unid
	, TaskNumber
	, TaskName
	, TaskStatus
	, IsPublic
	, TaskEndDate
	)
SELECT
	unid = unid
	, TaskNumber = taaknr
	, TaskName = taaknaam
	, TaskStatus = [status]
	, IsPublic = iedereen
	, TaskEndDate = einddatum
FROM
	[$(LIFT_Archive)].dbo.taak

PRINT 'Inserting data into [$(LIFTDW)].Dim.Nomination'
INSERT INTO
	[$(LIFTDW)].Dim.Nomination
	(
	unid
	, ProjectKey
	, CustomerKey
	, EmployeeKey
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
	)

/* Inserting personal nominations */
SELECT
	unid = v.unid
	, ProjectKey = COALESCE(p.ProjectKey, -1) -- Always matches
	, CustomerKey = COALESCE(c.CustomerKey, -1) -- Always matches
	, EmployeeKey = COALESCE(e.EmployeeKey, -1) -- Always matches, except for 181 cases (employeeid in source table is NULL in 181 cases)
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
FROM
	[$(LIFT_Archive)].dbo.voordracht v
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Project p ON p.unid = v.projectid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Customer c ON c.CustomerKey = p.CustomerKey
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.aanvraag a ON a.unid = v.aanvraagid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = v.employeeid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Ledger l ON l.unid = v.grootboekid
--		AND v.startdatum > e.ContractStartDate AND v.startdatum < e.ContractEndDate -- Disabled these conditions on 17-07-2017; this caused '-1' for ~25% of the cases for the EmployeeKey

UNION

/* Inserting activity group nominations */
SELECT
	unid = agv.unid
	, ProjectKey = COALESCE(p.ProjectKey, -1) -- Always matches
	, CustomerKey = COALESCE(c.CustomerKey, -1) -- Always matches
	, EmployeeKey = -1 -- Activity group nominations are not connected to specific employees
	, LedgerKey = COALESCE(l.LedgerKey, -1)
	, TaskKey = -1
	, RequestNumber = a.aanvraagnr
	, NominationName = ag.naam
	, PlanningStartDate = CAST(agv.startdatum_groep AS date)
	, PlanningEndDate = CAST(agv.einddatum_groep AS date)
	, WorkloadWeekly = agv.totale_werklast
	, HourlyRate = agv.uurprijs
	, ChangeDate = agv.datwijzig
	, Internal = agv.intern
	, NominationType = 'Activity Group'
	, [Status] = agv.[status]
FROM
	[$(LIFT_Archive)].dbo.activiteitgroep_voordracht agv
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Project p ON p.unid = agv.projectid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Customer c ON c.CustomerKey = p.CustomerKey
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.aanvraag a ON a.unid = agv.aanvraagid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Ledger l ON l.unid = agv.grootboekid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.activiteitgroep ag ON agv.activiteitgroepid = ag.unid

UNION

/* Inserting task nominations */
SELECT
	unid = tv.unid
	, ProjectKey = -1 -- Task nominations are internal and not connected to a project
	, CustomerKey = -1 -- Task nominations are internal and not connected to a customer
	, EmployeeKey = COALESCE(e.EmployeeKey, -1) -- Always matches
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
FROM
	[$(LIFT_Archive)].dbo.taakvoordracht tv
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = tv.employeeid
--		AND tv.startdatum > e.ContractStartDate AND tv.startdatum < e.ContractEndDate -- Disabled these conditions on 17-07-2017; this caused '-1' for ~25% of the cases for the EmployeeKey
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Task t ON t.unid = tv.taakid

UNION

/* Inserting generic task nominations */
SELECT
	unid = NULL -- Don't exist in LIFT
	, ProjectKey = -1 -- Task nominations are internal and not connected to a project
	, CustomerKey = -1 -- Task nominations are internal and not connected to a customer
	, EmployeeKey = COALESCE(e.EmployeeKey, -1) -- Always matches
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
FROM
	[$(LIFTDW)].Dim.Employee e
	CROSS APPLY [$(LIFTDW)].Dim.Task t
WHERE 1=1
	AND t.IsPublic = 1
--	AND t.TaskStatus = 1
	AND e.JoinDate < GETUTCDATE()
	AND e.ContractEndDate IS NOT NULL

PRINT 'Inserting data into [$(LIFTDW)].Dim.EmployeeContract'
INSERT INTO
	[$(LIFTDW)].Dim.EmployeeContract
	(
	unid
	, EmployeeKey
	, ContractCreationDate
	, ContractChangeDate
	, ContractStatus
	, ContractType
	, [Percentage]
	, ContractStartDate
	, ContractEndDate
	, SuggestedHourlyRate
	)
SELECT
	unid = wc.unid
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, ContractCreationDate = wc.dataanmk
	, ContractChangeDate = wc.datwijzig
	, ContractStatus = wc.[status]
	, ContractType = cs.tekst
	, [Percentage] = wc.procent
	, ContractStartDate = wc.startdatum
	, ContractEndDate = wc.einddatum
	, SuggestedHourlyRate = wc.uurtarief
FROM 
	[$(LIFT_Archive)].dbo.wcontract wc
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = wc.werknemerid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.contractsoort cs ON cs.unid = wc.contractsoortid

/* Inserting Requests */
PRINT 'Inserting data into [$(LIFTDW).Dim.Request'
INSERT INTO 
	[$(LIFTDW)].Dim.Request
	(
	unid
	, ProjectKey
	, RequestCreationDate
	, RequestChangeDate
	, RequestArchiveDate
	, RequestAcceptDate
	, RequestNumber
	, RequestStatus
	, SalesChannel
	, IsAdditionalRequest
	, RequestSalesTarget
	, SuccessChance
	, RequestValue
	)
SELECT
	unid = a.unid
	, ProjectKey = COALESCE(p.ProjectKey, -1)
	, RequestCreationDate = a.dataanmk
	, RequestChangeDate = a.datwijzig
	, RequestArchiveDate = a.archiefdatum
	, RequestAcceptDate = a.datacceptatie
	, RequestNumber = a.aanvraagnr
	, RequestStatus = a.[status]
	, SalesChannel = v.tekst
	, IsAdditionalRequest = a.is_additional_request
	, RequestSalesTarget = a.amount_quoted
	, SuccessChance = a.slagingspercentage
	, RequestValue = a.amount_quoted * a.slagingspercentage / 100
FROM
	[$(LIFT_Archive)].dbo.aanvraag a
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Project p ON a.projectid = p.unid 
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.project ap ON a.projectid = ap.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.vrijopzoek v ON ap.extraopz1 = v.unid AND v.kaartcode = 'EXTRAOPZ1PROJ'

/* Inserting hours */
PRINT 'Inserting data into [$(LIFTDW)].Fact.Hour'
INSERT INTO
	[$(LIFTDW)].Fact.[Hour]
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
	, [Hours] = COALESCE(u.seconds / 3600.0, u.old_amount)
	, [Day] = CAST(u.datum AS date)
	, ChangeDate = CAST(u.datwijzig AS date)
	, Rate = v.uurprijs
	, [Percentage] = ht.[Percentage]
	, Billable = ht.Billable
	, InvoiceProcessed = u.verwerkt_factuur
FROM
	[$(LIFT_Archive)].dbo.assignment_hour u
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.uurtype ut ON ut.unid = u.hourtypeid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Project p ON p.unid = ut.projectid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Customer c ON c.CustomerKey = p.CustomerKey
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.voordracht v ON v.unid = U.assignmentid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.dienst d ON v.productid = d.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = v.employeeid
--		AND U.datum > E.ContractStartDate AND U.datum < E.ContractEndDate -- Disabled these conditions on 17-07-2017; this caused '-1' for ~25% of the cases for the EmployeeKey
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.klant k ON k.unid = c.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.AccountManager am ON am.unid = k.behandelaarid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.HourType ht ON ht.Billable = ut.declarabel AND ht.[Percentage] = ut.procent AND ht.RateName = ut.tariefnaam
	LEFT OUTER JOIN [$(LIFTDW)].Dim.[Service] s ON s.ProductNomination = d.naam
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Ledger l ON l.unid = v.grootboekid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Nomination n ON n.unid = v.unid
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
	, [Hours] = COALESCE(u.seconds / 3600.0, u.old_amount)
	, [Day] = CAST(u.datum AS date)
	, ChangeDate = CAST(u.datwijzig AS date)
	, Rate = 0 -- Tasks do not generate turnover
	, [Percentage] = 100
	, Billable = 0
	, InvoiceProcessed = 0
FROM
	[$(LIFT_Archive)].dbo.task_assignment_hour u
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Nomination n ON n.unid = u.task_assignmentid
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
	, [Hours] = COALESCE(u.seconds / 3600.0, u.old_amount)
	, [Day] = CAST(u.datum AS date)
	, ChangeDate = CAST(u.datwijzig AS date)
	, Rate = 0 -- Tasks do not generate turnover
	, [Percentage] = 100
	, Billable = 0
	, InvoiceProcessed = 0
FROM
	[$(LIFT_Archive)].dbo.task_hour u
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = u.employeeid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Task t ON t.unid = u.taskid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Nomination n ON n.EmployeeKey = e.EmployeeKey AND n.TaskKey = t.TaskKey
WHERE 1=1
	AND u.datum > '2010-01-01'

/* Inserting planned workload into planning */
PRINT 'Inserting data into [$(LIFTDW)].Fact.Planning'

;WITH d AS (SELECT [Date] FROM [$(LIFTDW)].Dim.[Date] WHERE [DayOfWeek] NOT IN (6,7))

-- Planningtabel aangevuld met berekende einddatum van een uitzondering op een standaardwerklast
, PlanningWithEndDate AS
(
SELECT
	unid = coworkerid
	, startdatum = startdate
	, aantal = amount
	, einddatum = LAG(startdate) OVER (PARTITION BY coworkerid ORDER BY startdate DESC)
FROM
	[$(LIFT_Archive)].dbo.planning_coworker_availability
UNION
SELECT
	unid = assignmentid
	, startdatum = startdate
	, aantal = amount
	, einddatum = LAG(startdate) OVER (PARTITION BY assignmentid ORDER BY startdate DESC)
FROM
	[$(LIFT_Archive)].dbo.planning_assignment
UNION
SELECT
	unid = task_assignmentid
	, startdatum = startdate
	, aantal = amount
	, einddatum = LAG(startdate) OVER (PARTITION BY task_assignmentid ORDER BY startdate DESC)
FROM
	[$(LIFT_Archive)].dbo.planning_task_assignment
)

INSERT INTO
	[$(LIFTDW)].Fact.Planning
	(
	NominationKey
	, PlanningDate
	, WorkloadWeeklyDefault
	, WorkloadWeekly
	, WorkloadWeeklyAdjusted
	, EstimatedWorkloadDaily
	, EstimatedPlannedTurnover
	)
SELECT
	NominationKey = n.NominationKey
	, PlanningDate = d.[Date]
	, WorkloadWeeklyDefault = CAST(WorkloadWeekly AS decimal(9,2))
	, WorkloadWeekly = CAST(COALESCE(p.aantal, n.WorkloadWeekly) AS decimal(9,2))
	, WorkloadWeeklyAdjusted = CASE WHEN p.aantal IS NOT NULL THEN 1 ELSE 0 END
	, EstimatedWorkloadDaily = CAST(COALESCE(p.aantal, n.WorkloadWeekly) / 5.0 AS decimal(9,2))
	, EstimatedPlannedTurnover = n.HourlyRate * CAST(COALESCE(p.aantal, n.WorkloadWeekly) / 5.0 AS money)
FROM
	[$(LIFTDW)].Dim.Nomination n
	INNER JOIN d ON d.[Date] >= n.PlanningStartDate AND d.[Date] <= n.PlanningEndDate
	LEFT OUTER JOIN PlanningWithEndDate p ON p.unid = n.unid AND p.startdatum <= d.[Date] AND (einddatum > d.[Date] OR einddatum IS NULL)
WHERE 1=1
	AND n.PlanningEndDate > '2015-12-31'
	AND n.NominationType <> 'Public Task'

/* Inserting planned workload into planning history */
-- Planning History are the planned hours for date X as measured on date X
PRINT 'Inserting data into [LIFTDW].Fact.PlanningHistory'

;WITH d AS (SELECT [Date] FROM [$(LIFTDW)].Dim.[Date] WHERE [DayOfWeek] NOT IN (6,7))

, AllHistoricNominations AS -- These are all nomination records (current and historic), code similar to Dim.Nomination
(
/* Personal nominations */
SELECT
	unid
	, startdatum = CAST(startdatum AS date)
	, einddatum = CAST(einddatum AS date)
	, werklast
	, uurprijs
	, datwijzig
	, ValidFrom
	, ValidTo
FROM
	[$(LIFT_Archive)].dbo.voordracht -- Current records
UNION
SELECT
	unid
	, startdatum = CAST(startdatum AS date)
	, einddatum = CAST(einddatum AS date)
	, werklast
	, uurprijs
	, datwijzig
	, ValidFrom
	, ValidTo
FROM
	[$(LIFT_Archive)].History.voordracht -- Old records

UNION

/* Activity group nominations */
SELECT
	unid
	, startdatum = CAST(startdatum_groep AS date)
	, einddatum = CAST(einddatum_groep AS date)
	, totale_werklast
	, uurprijs
	, datwijzig
	, ValidFrom
	, ValidTo
FROM
	[$(LIFT_Archive)].dbo.activiteitgroep_voordracht -- Current records
UNION
SELECT
	unid
	, startdatum = CAST(startdatum_groep AS date)
	, einddatum = CAST(einddatum_groep AS date)
	, totale_werklast
	, uurprijs
	, datwijzig
	, ValidFrom
	, ValidTo
FROM
	[$(LIFT_Archive)].History.activiteitgroep_voordracht -- Old records

UNION

/* Task nominations */
SELECT
	unid
	, startdatum = CAST(startdatum AS date)
	, einddatum = CAST(einddatum AS date)
	, werklast
	, uurprijs = 0.00
	, datwijzig
	, ValidFrom
	, ValidTo
FROM
	[$(LIFT_Archive)].dbo.taakvoordracht -- Current records
UNION
SELECT
	unid
	, startdatum = CAST(startdatum AS date)
	, einddatum = CAST(einddatum AS date)
	, werklast
	, uurprijs = 0.00
	, datwijzig
	, ValidFrom
	, ValidTo
FROM
	[$(LIFT_Archive)].History.taakvoordracht -- Old records
)

, AllHistoricPlanningRecords AS -- From one record per nomination to many records per nomination, one for each date within the nomination runtime (start-end date)
(
SELECT
	AHN.unid -- Personal nominations
	, # = ROW_NUMBER() OVER (PARTITION BY AHN.unid, d.[Date] ORDER BY AHN.datwijzig DESC) -- #1 is the latest version
	, NominationKey = COALESCE(n.NominationKey, -1) -- We ignore historic records in source tables that generated the Dim tables (used as foreign keys). Else we would need historic tables for every dim table. Hence it can occur that a NominationKey no longer exists.
	, PlanningDate = d.[Date]
	, EstimatedWorkloadDaily = CAST(AHN.werklast / 5.0 AS numeric(9,2))
	, EstimatedPlannedTurnover = AHN.uurprijs * CAST(AHN.werklast / 5.0 AS money)
FROM 
	AllHistoricNominations AHN
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Nomination n ON n.unid = AHN.unid 
	INNER JOIN d ON 1=1
		AND d.[Date] >= AHN.startdatum
		AND d.[Date] <= AHN.einddatum
		AND d.[Date] >= CAST(AHN.datwijzig AS date) -- Changes on the day itself are allowed
		AND d.[Date] <= CAST(AHN.ValidTo AS date) -- This clause is needed to discard older records that have a later v.einddatum than the newer records
WHERE 1=1
	AND d.[Date] >= '2017-01-01' -- Temporal table feature was switched on around this time
	AND d.[Date] < CAST(SYSDATETIME() AS date)
)

INSERT INTO
	[$(LIFTDW)].Fact.PlanningHistory
	(
	NominationKey
	, PlanningDate
	, EstimatedWorkloadDaily
	, EstimatedPlannedTurnover
	)
/* Inserting historic planned workload*/
SELECT
	NominationKey
	, PlanningDate
	, EstimatedWorkloadDaily
	, EstimatedPlannedTurnover
FROM
	AllHistoricPlanningRecords
WHERE 1=1
	AND # = 1

/* Inserting data related to courses and diplomas */

PRINT 'Inserting data into [$(LIFTDW)].Dim.Course'
INSERT INTO
	[$(LIFTDW)].Dim.Course
	(
	unid
	, EmployeeKey
	, [Provider]
	, CourseName
	, CourseDate
	, CourseEndDate
	, CourseDuration
	, DiplomaObtained
	)
SELECT
	unid = c.unid
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, [Provider] = c.leverancier
	, CourseName = c.naam
	, CourseDate = c.cursusdatum
	, CourseEndDate = c.einddatum
	, CourseDuration = c.dagen
	, DiplomaObtained = c.diploma
FROM
	[$(LIFT_Archive)].dbo.cursus c
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = c.werknemerid

PRINT 'Inserting data into [$(LIFTDW)].Dim.Diploma'
INSERT INTO
	[$(LIFTDW)].Dim.Diploma
	(
	unid
	, Diploma
	)
SELECT
	unid = d.unid
	, Diploma = d.tekst
FROM
	[$(LIFT_Archive)].dbo.diploma d

PRINT 'Inserting data into [$(LIFTDW)].Fact.EmployeeDiploma'
INSERT INTO 
	[$(LIFTDW)].Fact.EmployeeDiploma
	(
	unid
	, EmployeeKey
	, DiplomaKey
	, ExpirationDate
	)
SELECT
	unid = wd.unid
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, DiplomaKey = COALESCE(d.DiplomaKey, -1)
	, ExpirationDate = wd.expiration_date
FROM
	[$(LIFT_Archive)].dbo.werknemerdiploma wd
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Employee e ON e.unid = wd.werknemerid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Diploma d ON d.unid = wd.diplomaid

PRINT 'Inserting data into [$(LIFTDW)].Fact.Appointment'
INSERT INTO
	[$(LIFTDW)].Fact.Appointment
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
	, Result = ar.tekst
	, Category = wc.tekst
	, AcquisitionGoal = ag.tekst
	, AppointmentType = 'Customer'
	, [Subject] = NULL
FROM
	[$(LIFT_Archive)].dbo.appointmentcustomer ac
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.accountmanager am ON ac.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Customer cu ON ac.customerid = cu.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.afspraak_resultaat ar ON ac.resultaatid = ar.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.wfcategorie wc ON ac.wfcategorieid = wc.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.acquisition_goal ag ON ac.acquisition_goalid = ag.unid

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
	, Result = ar.tekst
	, Category = wc.tekst
	, AcquisitionGoal = ag.tekst
	, AppointmentType = 'ContactPerson'
	, [Subject] = NULL
FROM
	[$(LIFT_Archive)].dbo.appointmentcustomercontact ac
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.accountmanager am ON ac.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.ContactPerson cp ON ac.customercontactid = cp.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Customer cu ON cp.CustomerKey = cu.CustomerKey
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.afspraak_resultaat ar ON ac.resultaatid = ar.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.wfcategorie wc ON ac.wfcategorieid = wc.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.acquisition_goal ag ON ac.acquisition_goalid = ag.unid

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
	, Result = ar.tekst
	, Category = wc.tekst
	, AcquisitionGoal = ag.tekst
	, AppointmentType = 'Project'
	, [Subject] = ac.onderwerp
FROM
	[$(LIFT_Archive)].dbo.appointmentproject ac
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.accountmanager am ON ac.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Project p ON ac.projectid = p.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.afspraak_resultaat ar ON ac.resultaatid = ar.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.wfcategorie wc ON ac.wfcategorieid = wc.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.acquisition_goal ag ON ac.acquisition_goalid = ag.unid

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
	, Result = ar.tekst
	, Category = wc.tekst
	, AcquisitionGoal = ag.tekst
	, AppointmentType = 'Request'
	, [Subject] = apr.onderwerp
FROM
	[$(LIFT_Archive)].dbo.appointmentrequest apr
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.accountmanager am ON apr.behandelaarid = am.gebruikerid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.AccountManager acm ON am.unid = acm.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.aanvraag a ON apr.requestid = a.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Request r ON a.unid = r.unid
	LEFT OUTER JOIN [$(LIFTDW)].Dim.Project p ON r.ProjectKey = p.ProjectKey
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.afspraak_resultaat ar ON apr.resultaatid = ar.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.wfcategorie wc ON apr.wfcategorieid = wc.unid
	LEFT OUTER JOIN [$(LIFT_Archive)].dbo.acquisition_goal AG ON apr.acquisition_goalid = ag.unid

/********************************************************************************
Insert the last load date of LiftDW into log.LastLoad
********************************************************************************/

PRINT 'Inserting last load date into [$(LIFTDW)].log.LastLoad'
EXEC ('INSERT INTO ' + @dbName + '.[log].LastLoad DEFAULT VALUES')

/* Reset all customer to inactive */

UPDATE [$(LIFTDW)].Dim.Customer
SET CustomerActive = 0

/* Set active customer */

UPDATE [$(LIFTDW)].Dim.Customer
SET CustomerActive = 1
WHERE CustomerKey IN (SELECT CustomerKey FROM [$(LIFTDW)].Dim.Project WHERE ProjectStatus = 2 GROUP BY CustomerKey)

/********************************************************************************
Recreate the FK`s
********************************************************************************/

PRINT 'Create foreign keys'
EXEC shared.EnableForeignKeys @dbName

/********************************************************************************
Assign the permissions
********************************************************************************/

EXEC shared.LoadRolePermissions @dbName
EXEC shared.AssignRolePermissions @dbName

END

/*
EXEC liftetl.LoadLiftDW
*/