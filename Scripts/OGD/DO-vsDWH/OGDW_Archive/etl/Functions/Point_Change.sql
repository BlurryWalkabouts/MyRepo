-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Change viewed as it was on the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [etl].[Point_Change]
(
	@changingTimepoint datetime2(0)
)
RETURNS TABLE
AS
RETURN

SELECT
	SourceDatabaseKey
	, AuditDWKey
--	, ChangeID = NULL

	, OperatorSimpleChange
	, OperatorEvaluationExtChange
	, OperatorProgressExtChange
	, OperatorRequestChange
	, OperatorGroupID = NULL
	, OperatorGroup

	, CustomerName
	, ChangeNumber
	, CardCreatedBy
	, CreationDate
	, CardChangedBy
	, ChangeDate
	, Category
	, Subcategory

	, ProcessingStatus
	, [Type]
	, ChangeType
	, ChangeTypeID = NULL
	, [Status]
	, CurrentPhase
	, CurrentPhaseID = NULL
	, Impact
	, Urgency = COALESCE(Urgency, IsUrgent)
	, [Priority]

	, RequestDate
	, Rejected
	, RejectionDate
	, AuthorizationDate
	, ClosureDateSimpleChange
	, SubmissionDateRequestChange
	, NoGoDateExtChange
	, CancelDateExtChange
	, Implemented
	, PlannedAuthDateRequestChange
	, PlannedFinalDate
	, PlannedImplDate
	, PlannedStartDateSimpleChange
	, ImplDateSimpleChange
	, ImplDateExtChange
	, EndDateExtChange
	, StartDateSimpleChange
	, Closed
	, [Started]

	, Coordinator
	, DateCalcTypeEvaluation
	, DateCalcTypeEvaluationID = NULL
	, DateCalcTypeProgress
	, DateCalcTypeProgressID = NULL
	, DateCalcTypeRequestChange
	, DateCalcTypeRequestChangeID = NULL
	, Evaluation
	, ExternalNumber
	, CancelledByOperator
	, CancelledByManager
	, TimeSpent

	, DescriptionBrief
--	, MajorIncidentId = NULL
	, ObjectID
	, OriginalIncident
	, Template

	, CallerName = COALESCE(CallerName,'')
	, CallerEmail
	, CallerTelephoneNumber
	, CallerDepartment = Department
	, CallerBranch

--	, CallerLocation

--	, ValidFrom
--	, ValidTo
FROM
	FileImport.[Changes] FOR SYSTEM_TIME AS OF @changingTimepoint

UNION

SELECT
	SourceDatabaseKey = c.SourceDatabaseKey
	, AuditDWKey = c.AuditDWKey
--	, ChangeID = c.unid

	, OperatorSimpleChange = NULL
	, OperatorEvaluationExtChange = NULL
	, OperatorProgressExtChange = NULL
	, OperatorRequestChange = NULL
	, OperatorGroupID = c.operatorgroupid
	, OperatorGroup = a4.ref_dynanaam

	, CustomerName = ve.naam
	, Changenumber = c.number
	, CardCreatedBy = g1.naam
	, CreationDate = c.dataanmk
	, CardChangedBy = g2.naam
	, ChangeDate = c.datwijzig
	, Category = c1.naam
	, Subcategory = c2.naam

	, ProcessingStatus = NULL
	, [Type] = wa.naam
	, ChangeType = NULL
	, ChangeTypeID = c.changetype
	, [Status] = ws.naam
	, CurrentPhase = NULL
	, CurrentPhaseID = c.currentphase
	, Impact = wi.naam
	, Urgency = c.isurgent
	, [Priority] = cp.naam

	, RequestDate = c.calldate
	, Rejected = c.rejected
	, RejectionDate = c.rejecteddate
	, AuthorizationDate = c.authorizationdate
	, ClosureDateSimpleChange = c.closeddate
	, SubmissionDateRequestChange = c.submitdate
	, NoGoDateExtChange = c.pro_rejecteddate
	, CancelDateExtChange = c.canceldate
	, Implemented = c.completed
	, PlannedAuthDateRequestChange = c.plannedauthdate
	, PlannedFinalDate = c.plannedfinaldate
	, PlannedImplDate = c.plannedimpldate
	, PlannedStartDateSimpleChange = c.plannedstartdate
	, ImplDateSimpleChange = c.completeddate
	, ImplDateExtChange = c.implementationdate
	, EndDateExtChange = c.finaldate
	, StartDateSimpleChange = c.starteddate
	, Closed = c.closed
	, [Started] = c.[started]

	, Coordinator = CASE
                        WHEN a3.ref_dynanaam IS NOT NULL AND a3.ref_dynanaam <> '' THEN a3.ref_dynanaam
                        WHEN a3.ref_dynanaam IS NOT NULL AND a3.ref_dynanaam = '' THEN a3.naam
                        WHEN a3.ref_dynanaam IS NULL AND a3.naam = '' THEN NULL
                        ELSE a3.naam
                    END
	, DateCalcTypeEvaluation = NULL
	, DateCalcTypeEvaluationID = c.calc_type_finaldate
	, DateCalcTypeProgress = NULL
	, DateCalcTypeProgressID = c.calc_type_impldate
	, DateCalcTypeRequestChange = NULL
	, DateCalcTypeRequestChangeID = c.calc_type_authdate
	, Evaluation = c.withevaluation
	, ExternalNumber = c.externalnumber
	, CancelledByOperator = a1.ref_dynanaam
	, CancelledByManager = a2.ref_dynanaam
	, TimeSpent = c.timetaken

	, DescriptionBrief = c.briefdescription
--	, MajorIncidentId = ic.majorincidentid
	, ObjectID = ob.ref_naam
	, OriginalIncident = ic.naam
	, Template = ct.briefdescription

	, CallerName = COALESCE(c.aanmeldernaam,'')
	, CallerEmail = c.aanmelderemail
	, CallerTelephoneNumber = c.aanmeldertelefoon
	, CallerDepartment = af.naam
	, CallerBranch = ve.naam
FROM
	TOPdesk.change FOR SYSTEM_TIME AS OF @changingTimepoint c
	LEFT OUTER JOIN TOPdesk.actiedoor        FOR SYSTEM_TIME AS OF @changingTimepoint a1 ON a1.unid = c.canceledbyoperatorid AND a1.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.actiedoor        FOR SYSTEM_TIME AS OF @changingTimepoint a2 ON a2.unid = c.canceledbypersonid   AND a2.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.actiedoor        FOR SYSTEM_TIME AS OF @changingTimepoint a3 ON a3.unid = c.managerid            AND a3.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.actiedoor        FOR SYSTEM_TIME AS OF @changingTimepoint a4 ON a4.unid = c.operatorgroupid      AND a4.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.gebruiker        FOR SYSTEM_TIME AS OF @changingTimepoint g1 ON g1.unid = c.uidaanmk             AND g1.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.gebruiker        FOR SYSTEM_TIME AS OF @changingTimepoint g2 ON g2.unid = c.uidwijzig            AND g2.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie    FOR SYSTEM_TIME AS OF @changingTimepoint c1 ON c1.unid = c.categoryid           AND c1.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie    FOR SYSTEM_TIME AS OF @changingTimepoint c2 ON c2.unid = c.subcategoryid        AND c2.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.vestiging        FOR SYSTEM_TIME AS OF @changingTimepoint ve ON ve.unid = c.aanmeldervestigingid AND ve.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.afdeling         FOR SYSTEM_TIME AS OF @changingTimepoint af ON af.unid = c.aanmelderafdelingid  AND af.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.wijziging_impact FOR SYSTEM_TIME AS OF @changingTimepoint wi ON wi.unid = c.impactid             AND wi.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.[object]         FOR SYSTEM_TIME AS OF @changingTimepoint ob ON ob.unid = c.objectid             AND ob.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.incident         FOR SYSTEM_TIME AS OF @changingTimepoint ic ON ic.unid = c.incidentid           AND ic.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.change_priority  FOR SYSTEM_TIME AS OF @changingTimepoint cp ON cp.unid = c.priorityid           AND cp.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.wijzigingstatus  FOR SYSTEM_TIME AS OF @changingTimepoint ws ON ws.unid = c.statusid             AND ws.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.change_template  FOR SYSTEM_TIME AS OF @changingTimepoint ct ON ct.unid = c.templateid           AND ct.SourceDatabaseKey = c.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.wbaanvraagtype   FOR SYSTEM_TIME AS OF @changingTimepoint wa ON wa.unid = c.typeid               AND wa.SourceDatabaseKey = c.SourceDatabaseKey
-- added:
--	LEFT OUTER JOIN TOPdesk.locatie          FOR SYSTEM_TIME AS OF @changingTimepoint lo ON lo.unid = c.aanmelderlokatieid   AND lo.SourceDatabaseKey = c.SourceDatabaseKey