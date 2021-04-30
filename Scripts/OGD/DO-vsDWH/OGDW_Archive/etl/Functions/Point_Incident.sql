-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Incident viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [etl].[Point_Incident]
(
	@changingTimepoint datetime2(0)
)
RETURNS TABLE
AS
RETURN

SELECT
	SourceDatabaseKey
	, AuditDWKey
--	, IncidentID = NULL

	, OperatorID = NULL
	, OperatorName
	, OperatorGroupID = NULL
	, OperatorGroup

	, CustomerName
	, IncidentNumber
	, CardCreatedBy
	, CreationDate
	, CardChangedBy
	, ChangeDate
	, Category
	, Subcategory

	, EntryType = COALESCE(EntryType,'')
	, IncidentType = COALESCE(IncidentType,'')
	, [Status] = COALESCE([Status],'')
	, Impact
	, [Priority] = COALESCE([Priority],'')

	, IncidentDate
	, Closed
	, ClosureDate
	, TargetDate
	, CompletionDate
	, OnHoldDate
	, Completed
	, Line
	, LineID = NULL
	, Onhold

	, Duration
	, DurationAdjusted
	, DurationOnHold
	, DurationActual
--	, NumberOfDaysCurrent
	, TimeSpentFirstLine
	, TimeSpentSecondLine
	, TotalTime

	, ServiceWindow
	, Sla
	, SlaAchieved
	, SlaAchievedID = NULL
	, SlaTargetDate
	, SlaContract
	, SlaLevel
	, StandardSolution

	, ExternalNumber

	, IncidentDescription
	, IsMajorIncident
	, MajorIncident
--	, MajorIncidentID = NULL
	, ConfigurationID
	, ObjectID
	, Supplier

	, CallerName = COALESCE(CallerName,'')
	, CallerEmail
	, CallerTelephoneNumber
--	, CallerMobileNumber
--	, CallerGender
--	, CallerGenderID = NULL
	, CallerDepartment = Department
	, CallerBranch
--	, CallerCity

--	, CallerLocation

--	, ValidFrom
--	, ValidTo
FROM
	FileImport.Incidents FOR SYSTEM_TIME AS OF @changingTimepoint

UNION

SELECT
	SourceDatabaseKey = i.SourceDatabaseKey
	, AuditDWKey = i.AuditDWKey
--	, IncidentID = NULL

	, OperatorID = i.operatorid
	, OperatorName = i.ref_operatordynanaam
	, OperatorGroupID = i.operatorgroupid
	, OperatorGroup = i.ref_operatorgroup

	, CustomerName = ve.naam
	, Incidentnumber = i.naam
	, CardCreatedBy = g1.naam
	, CreationDate = i.dataanmk
	, CardChangedBy = g2.naam
	, ChangeDate = i.datwijzig
	, Category = c1.naam
	, Subcategory = c2.naam

	, EntryType = COALESCE(bk.naam,'')
	, IncidentType = COALESCE(sm.naam,'')
	, [Status] = COALESCE(ah.naam,'')
	, Impact = im.naam
	, [Priority] = COALESCE(pr.naam,'')

	, IncidentDate = i.datumaangemeld
	, Closed = i.afgemeld
	, ClosureDate = i.datumafgemeld
	, TargetDate = i.datumafspraak
	, CompletionDate = i.datumgereed
	, OnHoldDate = i.onholddatum
	, Completed = i.gereed
	, Line = NULL
	, LineID = i.[status]
	, Onhold = i.onhold

	, Duration = dt.naam
	, DurationAdjusted = i.adjusteddurationonhold
	, DurationOnHold = i.onholdduration
	, DurationActual = i.minutendoorlooptijd
--	, NumberOfDaysCurrent = NULL
	, TimeSpentFirstLine = i.lijn1tijdbesteed
	, TimeSpentSecondLine = i.tijdbesteed
	, TotalTime = i.totaletijd

	, ServiceWindow = sw.naam
	, Sla = dl.ref_naam
	, SlaAchieved = NULL
	, SlaAchievedID = i.dnostatus
	, SlaTargetDate = i.datumafspraaksla
	, SlaContract = dc.naam
	, SlaLevel = '' -- veld is vervallen , was voorheen dnoniveau.naam as
	, StandardSolution = op.korteomschrijving

	, ExternalNumber = i.externnummer

	, IncidentDescription = i.korteomschrijving
	, IsMajorIncident = i.ismajorincident
	, MajorIncident = i2.naam
--	, MajorIncidentID = i.majorincidentid
	, ConfigurationID = cf.naam
	, ObjectID = ob.ref_naam
	, Supplier =lv.naam

	, CallerName = COALESCE(i.aanmeldernaam,'')
	, CallerEmail = i.aanmelderemail
	, CallerTelephoneNumber = i.aanmeldertelefoon
--	, CallerMobileNumber = ps.mobiel
--	, CallerGender = NULL
--	, CallerGenderID = ps.geslacht
	, CallerDepartment = af.naam
	, CallerBranch = ve.naam
--	, CallerCity = ps.plaats

--	, CallerLocation

--	, ValidFrom
--	, ValidTo
FROM
	TOPdesk.incident FOR SYSTEM_TIME AS OF @changingTimepoint i
	LEFT OUTER JOIN TOPdesk.persoon           FOR SYSTEM_TIME AS OF @changingTimepoint ps ON ps.unid = i.persoonid            AND ps.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.gebruiker         FOR SYSTEM_TIME AS OF @changingTimepoint g1 ON g1.unid = i.uidaanmk             AND g1.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.gebruiker         FOR SYSTEM_TIME AS OF @changingTimepoint g2 ON g2.unid = i.uidwijzig            AND g2.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie     FOR SYSTEM_TIME AS OF @changingTimepoint c1 ON c1.unid = i.incident_domeinid    AND c1.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie     FOR SYSTEM_TIME AS OF @changingTimepoint c2 ON c2.unid = i.incident_specid      AND c2.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.configuratie      FOR SYSTEM_TIME AS OF @changingTimepoint cf ON cf.unid = i.configuratieid       AND cf.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.vestiging         FOR SYSTEM_TIME AS OF @changingTimepoint ve ON ve.unid = i.aanmeldervestigingid AND ve.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.afdeling          FOR SYSTEM_TIME AS OF @changingTimepoint af ON af.unid = i.aanmelderafdelingid  AND af.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.doorlooptijd      FOR SYSTEM_TIME AS OF @changingTimepoint dt ON dt.unid = i.doorlooptijdid       AND dt.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.soortbinnenkomst  FOR SYSTEM_TIME AS OF @changingTimepoint bk ON bk.unid = i.soortbinnenkomstid   AND bk.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.soortmelding      FOR SYSTEM_TIME AS OF @changingTimepoint sm ON sm.unid = i.soortmeldingid       AND sm.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.impact            FOR SYSTEM_TIME AS OF @changingTimepoint im ON sm.unid = i.impactid             AND im.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.incident          FOR SYSTEM_TIME AS OF @changingTimepoint i2 ON i2.unid = i.majorincidentid      AND i2.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.[object]          FOR SYSTEM_TIME AS OF @changingTimepoint ob ON ob.unid = i.configuratieobjectid AND ob.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.[priority]        FOR SYSTEM_TIME AS OF @changingTimepoint pr ON pr.unid = i.priorityid           AND pr.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.servicewindow     FOR SYSTEM_TIME AS OF @changingTimepoint sw ON sw.unid = i.servicewindowid      AND sw.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.dnolink           FOR SYSTEM_TIME AS OF @changingTimepoint dl ON dl.unid = i.dnoid                AND dl.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.dnocontract       FOR SYSTEM_TIME AS OF @changingTimepoint dc ON dc.unid = i.ref_dnocontractid    AND dc.SourceDatabaseKey = i.SourceDatabaseKey
--	LEFT OUTER JOIN TOPdesk.dnoniveau         FOR SYSTEM_TIME AS OF @changingTimepoint dn ON dn.unid = i.ref_dnoniveauid      AND dn.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.oplossingen       FOR SYSTEM_TIME AS OF @changingTimepoint op ON op.unid = i.oplossingid          AND op.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.afhandelingstatus FOR SYSTEM_TIME AS OF @changingTimepoint ah ON ah.unid = i.afhandelingstatusid  AND ah.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.leverancier       FOR SYSTEM_TIME AS OF @changingTimepoint lv ON lv.unid = i.supplierid           AND lv.SourceDatabaseKey = i.SourceDatabaseKey