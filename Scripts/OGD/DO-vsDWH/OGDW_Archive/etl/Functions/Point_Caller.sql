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

-- 1. Incidents from database import
SELECT
	i.SourceDatabaseKey
--	, CallerID = i.persoonid
	, ChangeDate = i.datwijzig
	, CallerName = COALESCE(i.aanmeldernaam,'')
	, CallerEmail = i.aanmelderemail
	, CallerTelephoneNumber = i.aanmeldertelefoon
	, CallerMobileNumber = p.mobiel
	, CallerDepartment = a.naam
	, CallerBranch = v.naam
	, CallerCity = v.plaats1
	, CallerLocation = l.naam
	, CallerGender = NULL
	, CallerGenderID = p.geslacht
FROM
	TOPdesk.incident FOR SYSTEM_TIME AS OF @changingTimepoint i
	LEFT OUTER JOIN TOPdesk.vestiging FOR SYSTEM_TIME AS OF @changingTimepoint v ON v.unid = i.aanmeldervestigingid AND v.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.afdeling  FOR SYSTEM_TIME AS OF @changingTimepoint a ON a.unid = i.aanmelderafdelingid  AND a.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.locatie   FOR SYSTEM_TIME AS OF @changingTimepoint l ON l.unid = i.aanmelderlokatieid   AND l.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.persoon   FOR SYSTEM_TIME AS OF @changingTimepoint p ON p.unid = i.persoonid            AND p.SourceDatabaseKey = i.SourceDatabaseKey

UNION

-- 2. Changes from database import
SELECT
	c.SourceDatabaseKey
--	, CallerID = NULL
	, ChangeDate = c.datwijzig
	, CallerName = COALESCE(c.aanmeldernaam,'')
	, CallerEmail = c.aanmelderemail
	, CallerTelephoneNumber = c.aanmeldertelefoon
	, CallerMobileNumber = NULL
	, CallerDepartment = a.naam
	, CallerBranch = v.naam
	, CallerCity = v.plaats1
	, CallerLocation = l.naam
	, CallerGender = NULL
	, CallerGenderID = NULL
FROM
	TOPdesk.change FOR SYSTEM_TIME AS OF @changingTimepoint c
	LEFT OUTER JOIN TOPdesk.vestiging FOR SYSTEM_TIME AS OF @changingTimepoint v ON v.unid = c.aanmeldervestigingid AND v.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.afdeling  FOR SYSTEM_TIME AS OF @changingTimepoint a ON a.unid = c.aanmelderafdelingid  AND a.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.locatie   FOR SYSTEM_TIME AS OF @changingTimepoint l ON l.unid = c.aanmelderlokatieid   AND l.SourceDatabaseKey = c.SourceDatabaseKey

UNION

-- 3. Incidents from file import
SELECT
	SourceDatabaseKey
--	, CallerID = NULL
	, ChangeDate
	, CallerName = COALESCE(CallerName,'')
	, CallerEmail
	, CallerTelephoneNumber
	, CallerMobileNumber
	, CallerDepartment = Department
	, CallerBranch
	, CallerCity
	, CallerLocation
	, CallerGender
	, CallerGenderID = NULL
FROM
	FileImport.Incidents FOR SYSTEM_TIME AS OF @changingTimepoint

UNION

-- 4. Changes from file import
SELECT
	SourceDatabaseKey
--	, CallerID = NULL
	, ChangeDate
	, CallerName = COALESCE(CallerName,'')
	, CallerEmail
	, CallerTelephoneNumber
	, CallerMobileNumber = NULL
	, CallerDepartment = Department
	, CallerBranch
	, CallerCity = NULL
	, CallerLocation
	, CallerGender = NULL
	, CallerGenderID = NULL
FROM
	FileImport.[Changes] FOR SYSTEM_TIME AS OF @changingTimepoint