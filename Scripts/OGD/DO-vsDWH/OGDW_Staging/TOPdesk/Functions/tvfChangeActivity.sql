CREATE function TOPdesk.tvfchangeactivity(@SourceDatabaseKey int, @AuditDWKey int) 
returns table as return (
with change as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.change
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,change_activitytemplate as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.change_activitytemplate
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,gebruiker2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.gebruiker
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,gebruiker as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.gebruiker
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,classificatie as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.classificatie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,actiedoor as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,actiedoor2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,changeactivity_status as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.changeactivity_status
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,classificatie2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.classificatie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
select changeactivity.AuditDWKey,  [change].[number] as [ActivityChange]
, [changeactivity].[number] as [ActivityNumber]
, [change_activitytemplate].[number] as [ActivityTemplate]
, [changeactivity].[approved] as [Approved]
, [changeactivity].[approveddate] as [ApprovedDate]
, [changeactivity].[briefdescription] as [BriefDescription]
, [gebruiker2].[naam] as [CardChangedBy]
, [gebruiker].[naam] as [CardCreatedBy]
, [classificatie].[naam] as [Category]
, [changeactivity].[ref_change_brief_description] as [ChangeBriefDescription]
, [changeactivity].[datwijzig] as [ChangeDate]
, [changeactivity].[changephase] as [ChangePhase]
, [changeactivity].[dataanmk] as [CreationDate]
, [changeactivity].[currentplantimetaken] as [CurrentPlanTimeTaken]
, [changeactivity].[maystart] as [MayStart]
, [actiedoor].[ref_dynanaam] as [OperatorGroup]
, [actiedoor2].[ref_dynanaam] as [OperatorName]
, [changeactivity].[originalplantimetaken] as [OriginalPlanTimeTaken]
, [changeactivity].[plannedfinaldate] as [PlannedFinalDate]
, [changeactivity].[plannedstartdate] as [PlannedStartDate]
, [changeactivity].[rejected] as [Rejected]
, [changeactivity].[rejecteddate] as [RejectedDate]
, [changeactivity].[resolved] as [Resolved]
, [changeactivity].[resolveddate] as [ResolvedDate]
, [changeactivity].[skipped] as [Skipped]
, [changeactivity].[skippeddate] as [SkippedDate]
, [changeactivity].[started] as [Started]
, [changeactivity].[starteddate] as [StartedDate]
, [changeactivity_status].[naam] as [Status]
, [classificatie2].[naam] as [Subcategory]
, [changeactivity].[timetaken] as [TimeTaken]

 from TOPdesk.changeactivity
left join change on change.unid = changeactivity.changeid and change.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and change.RN = 1
left join change_activitytemplate on change_activitytemplate.unid = changeactivity.activitytemplateid and change_activitytemplate.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and change_activitytemplate.RN = 1
left join gebruiker2 on gebruiker2.unid = changeactivity.uidwijzig and gebruiker2.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and gebruiker2.RN = 1
left join gebruiker on gebruiker.unid = changeactivity.uidaanmk and gebruiker.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and gebruiker.RN = 1
left join classificatie on classificatie.unid = changeactivity.categoryid and classificatie.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and classificatie.RN = 1
left join actiedoor on actiedoor.unid = changeactivity.operatorgroupid and actiedoor.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and actiedoor.RN = 1
left join actiedoor2 on actiedoor2.unid = changeactivity.operatorid and actiedoor2.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and actiedoor2.RN = 1
left join changeactivity_status on changeactivity_status.unid = changeactivity.activitystatusid and changeactivity_status.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and changeactivity_status.RN = 1
left join classificatie2 on classificatie2.unid = changeactivity.subcategoryid and classificatie2.SourceDatabaseKey = changeactivity.SourceDatabaseKey
 and classificatie2.RN = 1

where changeactivity.AuditDWKey = @AuditDWKey
)
