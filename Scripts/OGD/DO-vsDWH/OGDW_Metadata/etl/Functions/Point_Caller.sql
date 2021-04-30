-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Caller viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [etl].[Point_Caller]
(
	@changingTimepoint datetime2(0)
)
RETURNS TABLE
AS
RETURN

-- Concatenate all caller data from the four main sources
WITH EnrichedData AS
(
SELECT DISTINCT
	SourceDatabaseKey
--	, CallerID -- = COALESCE (src.CallerID, n.CallerID, e.CallerID)
	, ChangeDate
	, CallerName
	, CallerEmail = dbo.FormatEmailAddress(CallerEmail)
	, CallerTelephoneNumber = dbo.FormatPhoneNumber(CallerTelephoneNumber)
	, CallerMobileNumber = dbo.FormatPhoneNumber(CallerMobileNumber)
	, CallerDepartment
	, CallerBranch
	, CallerCity
	, CallerLocation
	, CallerGender
	, CallerGenderID
FROM
	[$(OGDW_Archive)].etl.Point_Caller(@changingTimepoint)
)

/*
For some some sources it is not enough to differentiate between callers solely on their names. In these cases an extra
column is selected. For each extra column a separate SELECT statement is required. Each SELECT statement groups the
callers from the respective sources by CallerName and the chosen extra column, and takes the most recent value for
all other columns.
*/

-- Take the most recent values for all callers from Officium, OGD and MKBO grouped by CallerName and CallerBranch
-- These are multi-customer databases
SELECT
	SourceDatabaseKey
	, CallerName
	, CallerEmail = FIRST_VALUE(CallerEmail) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
	, CallerTelephoneNumber = FIRST_VALUE(CallerTelephoneNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
	, CallerMobileNumber = FIRST_VALUE(CallerMobileNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
	, CallerDepartment = FIRST_VALUE(CallerDepartment) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
	, CallerBranch
	, CallerCity = FIRST_VALUE(CallerCity) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
	, CallerLocation = FIRST_VALUE(CallerLocation) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
	, CallerGender = FIRST_VALUE(CallerGender) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
	, CallerGenderID = FIRST_VALUE(CallerGenderID) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerBranch ORDER BY ChangeDate DESC)
FROM
	EnrichedData ed
WHERE 1<>1
	OR SourceDatabaseKey IN (9,21,40,343,344)

UNION

-- Take the most recent values for all callers from De Tweede Kamer grouped by CallerName and CallerDepartment
-- All callers are anonymous
SELECT
	SourceDatabaseKey
	, CallerName
	, CallerEmail = FIRST_VALUE(CallerEmail) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
	, CallerTelephoneNumber = FIRST_VALUE(CallerTelephoneNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
	, CallerMobileNumber = FIRST_VALUE(CallerMobileNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
	, CallerDepartment
	, CallerBranch = FIRST_VALUE(CallerBranch) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
	, CallerCity = FIRST_VALUE(CallerCity) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
	, CallerLocation = FIRST_VALUE(CallerLocation) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
	, CallerGender = FIRST_VALUE(CallerGender) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
	, CallerGenderID = FIRST_VALUE(CallerGenderID) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerDepartment ORDER BY ChangeDate DESC)
FROM
	EnrichedData ed
WHERE 1<>1
	OR SourceDatabaseKey IN (42,43)
	
UNION

-- Take the most recent values for all callers from Beweging3.0 and FloraHolland grouped by CallerName and CallerEmail
-- These databases have a large number of 'external' or 'unknown' callers
SELECT
	SourceDatabaseKey
	, CallerName
	, CallerEmail
	, CallerTelephoneNumber = FIRST_VALUE(CallerTelephoneNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
	, CallerMobileNumber = FIRST_VALUE(CallerMobileNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
	, CallerDepartment = FIRST_VALUE(CallerDepartment) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
	, CallerBranch = FIRST_VALUE(CallerBranch) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
	, CallerCity = FIRST_VALUE(CallerCity) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
	, CallerLocation = FIRST_VALUE(CallerLocation) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
	, CallerGender = FIRST_VALUE(CallerGender) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
	, CallerGenderID = FIRST_VALUE(CallerGenderID) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerEmail ORDER BY ChangeDate DESC)
FROM
	EnrichedData ed
WHERE 1<>1
	OR (SourceDatabaseKey =  10 AND CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick'))
	OR (SourceDatabaseKey = 323 AND CallerName IN ('Extern Aalsmeer,') AND CallerEmail IS NOT NULL)
	OR (SourceDatabaseKey = 324 AND CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick'))

UNION

-- Take the most recent values for all callers from FloraHolland (WHERE CallerEmail IS NULL) grouped by CallerName and CallerTelephoneNumber
SELECT
	SourceDatabaseKey
	, CallerName
	, CallerEmail = FIRST_VALUE(CallerEmail) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
	, CallerTelephoneNumber
	, CallerMobileNumber = FIRST_VALUE(CallerMobileNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
	, CallerDepartment = FIRST_VALUE(CallerDepartment) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
	, CallerBranch = FIRST_VALUE(CallerBranch) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
	, CallerCity = FIRST_VALUE(CallerCity) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
	, CallerLocation = FIRST_VALUE(CallerLocation) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
	, CallerGender = FIRST_VALUE(CallerGender) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
	, CallerGenderID = FIRST_VALUE(CallerGenderID) OVER (PARTITION BY SourceDatabaseKey, CallerName, CallerTelephoneNumber ORDER BY ChangeDate DESC)
FROM
	EnrichedData ed
WHERE 1<>1
	OR (SourceDatabaseKey = 323 AND CallerName IN ('Extern Aalsmeer,') AND CallerEmail IS NULL)
	
UNION

-- Default: In all other cases take the most recent values only grouped by CallerName
SELECT
	SourceDatabaseKey
	, CallerName
	, CallerEmail = FIRST_VALUE(CallerEmail) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerTelephoneNumber = FIRST_VALUE(CallerTelephoneNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerMobileNumber = FIRST_VALUE(CallerMobileNumber) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerDepartment = FIRST_VALUE(CallerDepartment) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerBranch = FIRST_VALUE(CallerBranch) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerCity = FIRST_VALUE(CallerCity) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerLocation = FIRST_VALUE(CallerLocation) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerGender = FIRST_VALUE(CallerGender) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
	, CallerGenderID = FIRST_VALUE(CallerGenderID) OVER (PARTITION BY SourceDatabaseKey, CallerName ORDER BY ChangeDate DESC)
FROM
	EnrichedData ed
WHERE 1=1
	AND NOT SourceDatabaseKey IN (9,21,40,343,344)
	AND NOT SourceDatabaseKey IN (42,43)
	AND NOT (SourceDatabaseKey =  10 AND CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick'))
	AND NOT (SourceDatabaseKey = 323 AND CallerName IN ('Extern Aalsmeer,') AND CallerEmail IS NOT NULL)
	AND NOT (SourceDatabaseKey = 324 AND CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick'))
	AND NOT (SourceDatabaseKey = 323 AND CallerName IN ('Extern Aalsmeer,') AND CallerEmail IS NULL)