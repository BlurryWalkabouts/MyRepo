CREATE function [TOPdesk].[tvfObject](@SourceDatabaseKey int, @AuditDWKey int) 
returns table as return (
with Attentie as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.Attentie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,budgethouder as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.budgethouder
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,configuratie as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.configuratie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,actiedoor as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,persoongroep as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.persoongroep
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,licentiesoort as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.licentiesoort
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,objectstatus as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.objectstatus
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
select Object.AuditDWKey,  [Attentie].[naam] as [Attention]
, [Object].[ref_vestiging] as [Branch]
, [budgethouder].[naam] as [Budgetholder]
, [Object].[ref_plaats] as [City]
, [Object].[type] as [Class]
, [Object].[ref_opmerking] as [Comments]
, [configuratie].[naam] as [Configuration]
, [actiedoor].[ref_dynanaam] as [Contact]
, [persoongroep].[naam] as [Group]
, [Object].[ref_hostnaam] as [Hostname]
, [Object].[ref_ipadres] as [IPAddress]
, [Object].[ref_leasecontractnummer] as [LeaseContractNumber]
, [Object].[ref_leaseeinddatum] as [LeaseEndDate]
, [Object].[ref_leaseperiode] as [LeasePeriod]
, [Object].[ref_leaseprijs] as [LeasePrice]
, [Object].[ref_leaseaanvangsdatum] as [LeaseStartDate]
, [licentiesoort].[naam] as [Licentieype]
, [Object].[ref_leverancier] as [Make]
, [Object].[ref_type] as [Model]
, [Object].[ref_naam] as [ObjectID]
, [Object].[ref_soort] as [ObjectType]
, [Object].[ref_ordernummer] as [OrderNumber]
, [Object].[ref_persoon] as [Person]
, [Object].[ref_aanschafdatum] as [PurchaseDate]
, [Object].[ref_aankoopbedrag] as [PurchasePrice]
, [Object].[ref_restwaarde] as [ResidualValue]
, [Object].[ref_lokatie] as [Room]
, [Object].[ref_serienummer] as [SerialNumber]
, [Object].[ref_specificatie] as [Specification]
, [Object].[ref_persoongroep] as [Staffgroup]
, [objectstatus].[naam] as [Status]
, [Object].[ref_leverancier] as [Supplier]
, [Object].[ref_gebruiker] as [User]
, A.DWDateCreated as ChangeDate --bij gebrek aan beter gebruiken we dit als ChangeDate
 from TOPdesk.Object
--join met log.Audit handmatig toegevoegd:
left join OGDW_Metadata.[log].[Audit] A on Object.AuditDWKey = A.AuditDWKey
left join Attentie on Attentie.unid = Object.ref_attentieid and Attentie.SourceDatabaseKey = Object.SourceDatabaseKey
 and Attentie.RN = 1
left join budgethouder on budgethouder.unid = Object.ref_budgethouderid and budgethouder.SourceDatabaseKey = Object.SourceDatabaseKey
 and budgethouder.RN = 1
left join configuratie on configuratie.unid = Object.ref_configuratieid and configuratie.SourceDatabaseKey = Object.SourceDatabaseKey
 and configuratie.RN = 1
left join actiedoor on actiedoor.unid = Object.ref_aanspreekpuntid and actiedoor.SourceDatabaseKey = Object.SourceDatabaseKey
 and actiedoor.RN = 1
left join persoongroep on persoongroep.unid = Object.ref_groepid and persoongroep.SourceDatabaseKey = Object.SourceDatabaseKey
 and persoongroep.RN = 1
left join licentiesoort on licentiesoort.unid = Object.ref_licentiesoortid and licentiesoort.SourceDatabaseKey = Object.SourceDatabaseKey
 and licentiesoort.RN = 1
left join objectstatus on objectstatus.unid = Object.statusid and objectstatus.SourceDatabaseKey = Object.SourceDatabaseKey
 and objectstatus.RN = 1

where Object.AuditDWKey = @AuditDWKey
)