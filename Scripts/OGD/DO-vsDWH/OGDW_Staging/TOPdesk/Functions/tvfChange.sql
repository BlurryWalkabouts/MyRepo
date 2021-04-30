CREATE function [TOPdesk].[tvfChange](@SourceDatabaseKey int, @AuditDWKey int) 
returns table as return (
with actiedoor2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,actiedoor as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,gebruiker as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.gebruiker
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,gebruiker2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.gebruiker
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,classificatie as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.classificatie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,actiedoor3 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,vestiging as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.vestiging
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,afdeling as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.afdeling
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,wijziging_impact as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.wijziging_impact
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,object as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.[object]
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,actiedoor4 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,incident as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.incident
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,change_priority as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.change_priority
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,wijzigingstatus as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.wijzigingstatus
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,classificatie2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.classificatie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,change_template as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.change_template
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,wbaanvraagtype as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.wbaanvraagtype
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
select change.AuditDWKey,  change.authorizationdate as AuthorizationDate
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
, change.unid as ChangeUnid
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
left join actiedoor2 on actiedoor2.unid = change.canceledbypersonid and actiedoor2.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor2.RN = 1
left join actiedoor on actiedoor.unid = change.canceledbyoperatorid and actiedoor.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor.RN = 1
left join gebruiker on gebruiker.unid = change.uidaanmk and gebruiker.SourceDatabaseKey = change.SourceDatabaseKey
 and gebruiker.RN = 1
left join gebruiker2 on gebruiker2.unid = change.uidwijzig and gebruiker2.SourceDatabaseKey = change.SourceDatabaseKey
 and gebruiker2.RN = 1
left join classificatie on classificatie.unid = change.categoryid and classificatie.SourceDatabaseKey = change.SourceDatabaseKey
 and classificatie.RN = 1
left join actiedoor3 on actiedoor3.unid = change.managerid and actiedoor3.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor3.RN = 1
left join vestiging on vestiging.unid = change.aanmeldervestigingid and vestiging.SourceDatabaseKey = change.SourceDatabaseKey
 and vestiging.RN = 1
left join afdeling on afdeling.unid = change.aanmelderafdelingid and afdeling.SourceDatabaseKey = change.SourceDatabaseKey
 and afdeling.RN = 1
left join wijziging_impact on wijziging_impact.unid = change.impactid and wijziging_impact.SourceDatabaseKey = change.SourceDatabaseKey
 and wijziging_impact.RN = 1
left join [object] on [object].unid = change.objectid and [object].SourceDatabaseKey = change.SourceDatabaseKey
 and [object].RN = 1
left join actiedoor4 on actiedoor4.unid = change.operatorgroupid and actiedoor4.SourceDatabaseKey = change.SourceDatabaseKey
 and actiedoor4.RN = 1
left join incident on incident.unid = change.incidentid and incident.SourceDatabaseKey = change.SourceDatabaseKey
 and incident.RN = 1
left join change_priority on change_priority.unid = change.priorityid and change_priority.SourceDatabaseKey = change.SourceDatabaseKey
 and change_priority.RN = 1
left join wijzigingstatus on wijzigingstatus.unid = change.statusid and wijzigingstatus.SourceDatabaseKey = change.SourceDatabaseKey
 and wijzigingstatus.RN = 1
left join classificatie2 on classificatie2.unid = change.subcategoryid and classificatie2.SourceDatabaseKey = change.SourceDatabaseKey
 and classificatie2.RN = 1
left join change_template on change_template.unid = change.templateid and change_template.SourceDatabaseKey = change.SourceDatabaseKey
 and change_template.RN = 1
left join wbaanvraagtype on wbaanvraagtype.unid = change.typeid and wbaanvraagtype.SourceDatabaseKey = change.SourceDatabaseKey
 and wbaanvraagtype.RN = 1

where change.AuditDWKey = @AuditDWKey
)