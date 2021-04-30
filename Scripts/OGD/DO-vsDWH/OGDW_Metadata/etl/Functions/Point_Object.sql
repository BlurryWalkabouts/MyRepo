-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Object viewed as it was ON the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [etl].[Point_Object]
(
	@changingTimepoint datetime2(0)
)
RETURNS TABLE
AS
RETURN

SELECT
	o.SourceDatabaseKey
	, o.AuditDWKey
	, ae.[naam] as [Attention]
	, o.[ref_vestiging] as [Branch]
	, bh.[naam] as [Budgetholder]
	, o.[ref_plaats] as [City]
	, o.[type] as [Class]
	, o.[ref_opmerking] as [Comments]
	, cf.[naam] as [Configuration]
	, ad.[ref_dynanaam] as [Contact]
	, pg.[naam] as [Group]
	, o.[ref_hostnaam] as [Hostname]
	, o.[ref_ipadres] as [IPAddress]
	, o.[ref_leasecontractnummer] as [LeaseContractNumber]
	, o.[ref_leaseeinddatum] as [LeaseEndDate]
	, o.[ref_leaseperiode] as [LeasePeriod]
	, o.[ref_leaseprijs] as [LeasePrice]
	, o.[ref_leaseaanvangsdatum] as [LeaseStartDate]
	, ls.[naam] as [LicentieType]
	, o.[ref_leverancier] as [Make]
	, o.[ref_type] as [Model]
	, o.[ref_naam] as [ObjectID]
	, o.[ref_soort] as [ObjectType]
	, o.[ref_ordernummer] as [OrderNumber]
	, o.[ref_persoon] as [Person]
	, o.[ref_aanschafdatum] as [PurchaseDate]
	, o.[ref_aankoopbedrag] as [PurchasePrice]
	, o.[ref_restwaarde] as [ResidualValue]
	, o.[ref_lokatie] as [Room]
	, o.[ref_serienummer] as [SerialNumber]
	, o.[ref_specificatie] as [Specification]
	, o.[ref_persoongroep] as [Staffgroup]
	, os.[naam] as [Status]
	, o.[ref_leverancier] as [Supplier]
	, o.[ref_gebruiker] as [User]
	, a.DWDateCreated as ChangeDate --bij gebrek aan beter gebruiken we dit als ChangeDate
FROM
	[$(OGDW_Archive)].TOPdesk.[object] /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ o
	LEFT OUTER JOIN [log].[Audit] a ON o.AuditDWKey = a.AuditDWKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.attentie      /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ ae ON ae.unid = o.ref_attentieid      AND ae.SourceDatabaseKey = o.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.budgethouder  /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ bh ON bh.unid = o.ref_budgethouderid  AND bh.SourceDatabaseKey = o.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.configuratie  /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ cf ON cf.unid = o.ref_configuratieid  AND cf.SourceDatabaseKey = o.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.actiedoor     /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ ad ON ad.unid = o.ref_aanspreekpuntid AND ad.SourceDatabaseKey = o.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.persoongroep  /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ pg ON pg.unid = o.ref_groepid         AND pg.SourceDatabaseKey = o.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.licentiesoort /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ ls ON ls.unid = o.ref_licentiesoortid AND ls.SourceDatabaseKey = o.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.objectstatus  /*FOR SYSTEM_TIME AS OF @changingTimepoint*/ os ON os.unid = o.statusid            AND os.SourceDatabaseKey = o.SourceDatabaseKey