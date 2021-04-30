CREATE function [TOPdesk].[tvfIncident](@SourceDatabaseKey int, @AuditDWKey int) 
returns table as return (

with persoon as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.persoon
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,gebruiker as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.gebruiker
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,configuratie as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.configuratie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,vestiging as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.vestiging
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,afdeling as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.afdeling
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,doorlooptijd as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.doorlooptijd
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,soortbinnenkomst as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.soortbinnenkomst
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,incident2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.incident
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,[object] as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.[object]
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,[priority] as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.[priority]
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,servicewindow as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.servicewindow
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,dnolink as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.dnolink
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,dnocontract as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.dnocontract
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,dnoniveau as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.dnoniveau
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,oplossingen as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.oplossingen
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,afhandelingstatus as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.afhandelingstatus
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,leverancier as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.leverancier
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
select incident.AuditDWKey, vestiging.naam as CallerBranch
, persoon.plaats as CallerCity
, incident.aanmelderemail as CallerEmail
, persoon.geslacht as CallerGenderID
, persoon.mobiel as CallerMobileNumber
, incident.aanmeldernaam as CallerName
, incident.aanmeldertelefoon as CallerTelephoneNumber
, gebruiker.naam as CardChangedBy
, gebruiker.naam as CardCreatedBy
, incident.ref_domein as Category
, incident.datwijzig as ChangeDate
, incident.afgemeld as Closed
, incident.datumafgemeld as ClosureDate
, incident.gereed as Completed
, incident.datumgereed as CompletionDate
, configuratie.naam as ConfigurationID
, incident.dataanmk as CreationDate
, vestiging.naam as CustomerName
, afdeling.naam as Department
, doorlooptijd.naam as Duration
, incident.minutendoorlooptijd as DurationActual
, incident.adjusteddurationonhold as DurationAdjusted
, incident.onholdduration as DurationOnHold
, soortbinnenkomst.naam as EntryType
, incident.externnummer as ExternalNumber
, incident.ref_impact as Impact
, incident.datumaangemeld as IncidentDate
, incident.korteomschrijving as IncidentDescription
, incident.naam as IncidentNumber
, incident.ref_soortmelding as IncidentType
, incident.ismajorincident as IsMajorIncident
, incident.[status] as LineID
, incident2.naam as MajorIncident
, incident.majorincidentid as MajorIncidentId
, [object].ref_naam as ObjectID
, incident.onhold as Onhold
, incident.onholddatum as OnHoldDate
, incident.ref_operatorgroup as OperatorGroup
, incident.ref_operatordynanaam as OperatorName
, [priority].naam as [Priority]
, servicewindow.naam as ServiceWindow
, dnolink.ref_naam as Sla
, incident.dnostatus as SlaAchievedID
, dnocontract.naam as SlaContract
, '' as SlaLevel -- veld is vervallen , was voorheen dnoniveau.naam as
, incident.datumafspraaksla as SlaTargetDate
, oplossingen.korteomschrijving as StandardSolution
, afhandelingstatus.naam as [Status]
, incident.ref_specificatie as Subcategory
, leverancier.naam as Supplier
, incident.datumafspraak as TargetDate
, incident.lijn1tijdbesteed as TimeSpentFirstLine
, incident.tijdbesteed as TimeSpentSecondLine
, incident.totaletijd as TotalTime

 from TOPdesk.incident
left join persoon on persoon.unid = incident.persoonid and persoon.SourceDatabaseKey = incident.SourceDatabaseKey
 and persoon.RN = 1
left join gebruiker on gebruiker.unid = incident.uidaanmk and gebruiker.SourceDatabaseKey = incident.SourceDatabaseKey
 and gebruiker.RN = 1
left join configuratie on configuratie.unid = incident.configuratieid and configuratie.SourceDatabaseKey = incident.SourceDatabaseKey
 and configuratie.RN = 1
left join vestiging on vestiging.unid = incident.aanmeldervestigingid and vestiging.SourceDatabaseKey = incident.SourceDatabaseKey
 and vestiging.RN = 1
left join afdeling on afdeling.unid = incident.aanmelderafdelingid and afdeling.SourceDatabaseKey = incident.SourceDatabaseKey
 and afdeling.RN = 1
left join doorlooptijd on doorlooptijd.unid = incident.doorlooptijdid and doorlooptijd.SourceDatabaseKey = incident.SourceDatabaseKey
 and doorlooptijd.RN = 1
left join soortbinnenkomst on soortbinnenkomst.unid = incident.soortbinnenkomstid and soortbinnenkomst.SourceDatabaseKey = incident.SourceDatabaseKey
 and soortbinnenkomst.RN = 1
left join incident2 on incident2.unid = incident.majorincidentid and incident2.SourceDatabaseKey = incident.SourceDatabaseKey
 and incident2.RN = 1
left join [object] on [object].unid = incident.configuratieobjectid and [object].SourceDatabaseKey = incident.SourceDatabaseKey
 and [object].RN = 1
left join [priority] on [priority].unid = incident.priorityid and [priority].SourceDatabaseKey = incident.SourceDatabaseKey
 and [priority].RN = 1
left join servicewindow on servicewindow.unid = incident.servicewindowid and servicewindow.SourceDatabaseKey = incident.SourceDatabaseKey
 and servicewindow.RN = 1
left join dnolink on dnolink.unid = incident.dnoid and dnolink.SourceDatabaseKey = incident.SourceDatabaseKey
 and dnolink.RN = 1
left join dnocontract on dnocontract.unid = incident.ref_dnocontractid and dnocontract.SourceDatabaseKey = incident.SourceDatabaseKey
 and dnocontract.RN = 1
-- left join dnoniveau on dnoniveau.unid = incident.ref_dnoniveauid and dnoniveau.SourceDatabaseKey = incident.SourceDatabaseKey
 -- and dnoniveau.RN = 1
left join oplossingen on oplossingen.unid = incident.oplossingid and oplossingen.SourceDatabaseKey = incident.SourceDatabaseKey
 and oplossingen.RN = 1
left join afhandelingstatus on afhandelingstatus.unid = incident.afhandelingstatusid and afhandelingstatus.SourceDatabaseKey = incident.SourceDatabaseKey
 and afhandelingstatus.RN = 1
left join leverancier on leverancier.unid = incident.supplierid and leverancier.SourceDatabaseKey = incident.SourceDatabaseKey
 and leverancier.RN = 1

where incident.AuditDWKey = @AuditDWKey
)