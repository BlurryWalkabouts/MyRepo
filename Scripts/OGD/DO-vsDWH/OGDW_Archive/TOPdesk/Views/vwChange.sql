


CREATE view [TOPdesk].[vwChange] as (
select change.SourceDatabaseKey,  change.AuditDWKey,
 change.authorizationdate as AuthorizationDate
, vestiging.naam as CallerBranch
, change.aanmelderemail as CallerEmail
, change.aanmeldernaam as CallerName
, change.aanmeldertelefoon as CallerTelephoneNumber
, change.canceldate as CancelDateExtChange
, actiedoor2.ref_dynanaam as CancelledByManager
, actiedoor.ref_dynanaam as CancelledByOperator
, gebruiker.naam as CardChangedBy
, gebruiker2.naam as CardCreatedBy
, classificatie.naam as Category
, change.datwijzig as ChangeDate
, change.number as ChangeNumber
, change.changetype as ChangeTypeID
, change.unid as Changeunid
, change.closed as Closed
, change.closeddate as ClosureDateSimpleChange
, actiedoor3.ref_dynanaam as Coordinator
, change.dataanmk as CreationDate
, change.currentphase as CurrentPhaseID
, vestiging.naam as CustomerName
, change.calc_type_finaldate as DateCalcTypeEvaluationID
, change.calc_type_impldate as DateCalcTypeProgressID
, change.calc_type_authdate as DateCalcTypeRequestChangeID
, afdeling.naam as Department
, change.briefdescription as DescriptionBrief
, change.finaldate as EndDateExtChange
, change.withevaluation as Evaluation
, change.externalnumber as ExternalNumber
, wijziging_impact.naam as Impact
, change.implementationdate as ImplDateExtChange
, change.completeddate as ImplDateSimpleChange
, change.completed as Implemented
, change.pro_rejecteddate as NoGoDateExtChange
, [object].ref_naam as ObjectID
, actiedoor4.ref_dynanaam as OperatorGroup
, incident.naam as OriginalIncident
, change.plannedauthdate as PlannedAuthDateRequestChange
, change.plannedfinaldate as PlannedFinalDate
, change.plannedimpldate as PlannedImplDate
, change.plannedstartdate as PlannedStartDateSimpleChange
, change_priority.naam as [Priority]
, change.rejected as Rejected
, change.rejecteddate as RejectionDate
, change.calldate as RequestDate
, change.starteddate as StartDateSimpleChange
, change.[started] as [Started]
, wijzigingstatus.naam as [Status]
, classificatie2.naam as Subcategory
, change.submitdate as SubmissionDateRequestChange
, change_template.briefdescription as Template
, change.timetaken as TimeSpent
, wbaanvraagtype.naam as [Type]
, change.isurgent as Urgency

 from TOPdesk.change
left join TOPdesk.actiedoor as actiedoor2 on actiedoor2.unid = change.canceledbypersonid and actiedoor2.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor2.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.actiedoor as actiedoor on actiedoor.unid = change.canceledbyoperatorid and actiedoor.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.gebruiker as gebruiker on gebruiker.unid = change.uidaanmk and gebruiker.SourceDatabaseKey = change.SourceDatabaseKey
 and gebruiker.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.gebruiker as gebruiker2 on gebruiker2.unid = change.uidwijzig and gebruiker2.SourceDatabaseKey = change.SourceDatabaseKey
 and gebruiker2.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.classificatie as classificatie on classificatie.unid = change.categoryid and classificatie.SourceDatabaseKey = change.SourceDatabaseKey
 and classificatie.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.actiedoor as actiedoor3 on actiedoor3.unid = change.managerid and actiedoor3.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor3.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.vestiging as vestiging on vestiging.unid = change.aanmeldervestigingid and vestiging.SourceDatabaseKey = change.SourceDatabaseKey
 and vestiging.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.afdeling as afdeling on afdeling.unid = change.aanmelderafdelingid and afdeling.SourceDatabaseKey = change.SourceDatabaseKey
 and afdeling.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.wijziging_impact as wijziging_impact on wijziging_impact.unid = change.impactid and wijziging_impact.SourceDatabaseKey = change.SourceDatabaseKey
 and wijziging_impact.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.[object] as [object] on [object].unid = change.objectid and [object].SourceDatabaseKey = change.SourceDatabaseKey
 and [object].SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.actiedoor as actiedoor4 on actiedoor4.unid = change.operatorgroupid and actiedoor4.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor4.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.incident as incident on incident.unid = change.incidentid and incident.SourceDatabaseKey = change.SourceDatabaseKey
 and incident.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.change_priority as change_priority on change_priority.unid = change.priorityid and change_priority.SourceDatabaseKey = change.SourceDatabaseKey
 and change_priority.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.wijzigingstatus as wijzigingstatus on wijzigingstatus.unid = change.statusid and wijzigingstatus.SourceDatabaseKey = change.SourceDatabaseKey
 and wijzigingstatus.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.classificatie as classificatie2 on classificatie2.unid = change.subcategoryid and classificatie2.SourceDatabaseKey = change.SourceDatabaseKey
 and classificatie2.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.change_template as change_template on change_template.unid = change.templateid and change_template.SourceDatabaseKey = change.SourceDatabaseKey
 and change_template.SourceDatabaseKey = change.SourceDatabaseKey
left join TOPdesk.wbaanvraagtype as wbaanvraagtype on wbaanvraagtype.unid = change.typeid and wbaanvraagtype.SourceDatabaseKey = change.SourceDatabaseKey
 and wbaanvraagtype.SourceDatabaseKey = change.SourceDatabaseKey

)



