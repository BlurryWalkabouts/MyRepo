


CREATE view [TOPdesk].[vwIncident] as (
select incident.SourceDatabaseKey, incident.AuditDWKey,
  vestiging.naam as CallerBranch
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
--, incident.adjustedduration as DurationAdjusted
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
--, dnoniveau.naam as SlaLevel
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
left join TOPdesk.persoon as persoon on persoon.unid = incident.persoonid and persoon.SourceDatabaseKey = incident.SourceDatabaseKey
 and persoon.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.gebruiker as gebruiker on gebruiker.unid = incident.uidaanmk and gebruiker.SourceDatabaseKey = incident.SourceDatabaseKey
 and gebruiker.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.configuratie as configuratie on configuratie.unid = incident.configuratieid and configuratie.SourceDatabaseKey = incident.SourceDatabaseKey
 and configuratie.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.vestiging as vestiging on vestiging.unid = incident.aanmeldervestigingid and vestiging.SourceDatabaseKey = incident.SourceDatabaseKey
 and vestiging.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.afdeling as afdeling on afdeling.unid = incident.aanmelderafdelingid and afdeling.SourceDatabaseKey = incident.SourceDatabaseKey
 and afdeling.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.doorlooptijd as doorlooptijd on doorlooptijd.unid = incident.doorlooptijdid and doorlooptijd.SourceDatabaseKey = incident.SourceDatabaseKey
 and doorlooptijd.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.soortbinnenkomst as soortbinnenkomst on soortbinnenkomst.unid = incident.soortbinnenkomstid and soortbinnenkomst.SourceDatabaseKey = incident.SourceDatabaseKey
 and soortbinnenkomst.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.incident as incident2 on incident2.unid = incident.majorincidentid and incident2.SourceDatabaseKey = incident.SourceDatabaseKey
 and incident2.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.[object] as [object] on [object].unid = incident.configuratieobjectid and [object].SourceDatabaseKey = incident.SourceDatabaseKey
 and [object].SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.[priority] as [priority] on [priority].unid = incident.priorityid and [priority].SourceDatabaseKey = incident.SourceDatabaseKey
 and [priority].SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.servicewindow as servicewindow on servicewindow.unid = incident.servicewindowid and servicewindow.SourceDatabaseKey = incident.SourceDatabaseKey
 and servicewindow.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.dnolink as dnolink on dnolink.unid = incident.dnoid and dnolink.SourceDatabaseKey = incident.SourceDatabaseKey
 and dnolink.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.dnocontract as dnocontract on dnocontract.unid = incident.ref_dnocontractid and dnocontract.SourceDatabaseKey = incident.SourceDatabaseKey
 and dnocontract.SourceDatabaseKey = incident.SourceDatabaseKey
--left join TOPdesk.dnoniveau as dnoniveau on dnoniveau.unid = incident.ref_dnoniveauid and dnoniveau.SourceDatabaseKey = incident.SourceDatabaseKey
-- and dnoniveau.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.oplossingen as oplossingen on oplossingen.unid = incident.oplossingid and oplossingen.SourceDatabaseKey = incident.SourceDatabaseKey
 and oplossingen.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.afhandelingstatus as afhandelingstatus on afhandelingstatus.unid = incident.afhandelingstatusid and afhandelingstatus.SourceDatabaseKey = incident.SourceDatabaseKey
 and afhandelingstatus.SourceDatabaseKey = incident.SourceDatabaseKey
left join TOPdesk.leverancier as leverancier on leverancier.unid = incident.supplierid and leverancier.SourceDatabaseKey = incident.SourceDatabaseKey
 and leverancier.SourceDatabaseKey = incident.SourceDatabaseKey

)



