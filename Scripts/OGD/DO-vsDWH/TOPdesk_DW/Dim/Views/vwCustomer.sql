CREATE VIEW [Dim].[vwCustomer]
AS

SELECT
	CustomerKey
	, DebitNumber
	, CustomerFullName = Fullname
	, CustomerSector
	, CustomerGroup
	, SLA
	, EndUserServiceType
	, SysAdminServiceType
	, SysAdminTeam
	, OutsourcingType
	, ServicesType
	, ExpectedChangeLoadPerMonth = ExpChaLoad
	, SupportWeekend
	, PostalCode = Postcode
	, SupportWindow
	, SupportWindowKey = SupportWindow_ID
	, NumberOfUsers = AantalGebruikers
	, NumberOfWorkplaces = AantalWerkplekken
	, OnCallService = Piketdienst
	, DateValidFrom = CAST(ValidFrom AS date)
	, DateValidTo = CAST(ValidTo AS date)
	, ActiveInReportPeriod = CASE WHEN DATEDIFF(MM, ValidTo, GETUTCDATE()) >= 13 THEN 0 ELSE 1 END
FROM 
	Dim.Customer
WHERE 1=1
	AND SysAdminTeam <> 'Geen'
	AND CustomerKey > -1