CREATE VIEW [log].[StagingRecordCount]
AS

SELECT
	a.AuditDWKey
	, a.SourceDatabaseKey
	, a.SourceName
	, a.SourceType
	, sub.SchemaName
	, sub.TableName
	, sub.RecordCount
	, a.DWDateCreated
	, a.AMDateImported
	, a.deleted
FROM
	[log].[Audit] a
	INNER JOIN ( 
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'attentie', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.attentie
	GROUP BY AuditDWKey
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'archiefreden', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.archiefreden
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'afhandelingstatus', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.afhandelingstatus
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'budgethouder', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.budgethouder
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'problem_priority', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.problem_priority
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'change_priority', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.change_priority
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'probleem_categorie', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.probleem_categorie
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'afdeling', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.afdeling
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'probleem_doorlooptijd', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.probleem_doorlooptijd
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'doorlooptijd', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.doorlooptijd
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'probleem_oorzaak', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.probleem_oorzaak
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'oplossingen', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.oplossingen
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'probleem_status', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.probleem_status
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'leverancier', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.leverancier
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'probleem_impact', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.probleem_impact
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'persoon', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.persoon
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'vrijeopzoekvelden', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.vrijeopzoekvelden
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'priority', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.[priority]
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'probleem', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.probleem
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'soortbinnenkomst', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.soortbinnenkomst
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'changeactivity_status', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.changeactivity_status
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'change_template', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.change_template
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'objectstatus', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.objectstatus
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'classificatie', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.classificatie
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'gebruiker', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.gebruiker
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'problem_urgency', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.problem_urgency
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'configuratie', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.configuratie
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'incident', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.incident
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'dnocontract', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.dnocontract
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'dnoniveau', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.dnoniveau
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'dnolink', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.dnolink
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'servicewindow', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.servicewindow
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'wijzigingstatus', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.wijzigingstatus
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'wijziging_impact', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.wijziging_impact
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'wbaanvraagtype', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.wbaanvraagtype
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'vestiging', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.vestiging
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'object', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.[object]
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'persoongroep', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.persoongroep
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'change_activitytemplate', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.change_activitytemplate
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'licentiesoort', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.licentiesoort
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'changeactivity', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.changeactivity
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'actiedoor', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.actiedoor
	GROUP BY AuditDWKey  
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'change_act_templ_dependency', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.change_act_templ_dependency
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'change', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.change
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'TOPdesk', TableName = 'version', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].TOPdesk.[version]
	GROUP BY AuditDWKey 
	UNION
	select AuditDWKey, SchemaName = 'FileImport', TableName = 'Changes', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].[FileImport].[Changes]
	GROUP BY AuditDWKey 
	UNION
	SELECT AuditDWKey, SchemaName = 'FileImport', TableName = 'Incidents', RecordCount = COUNT(*)
	FROM [$(OGDW_Staging)].[FileImport].Incidents
	GROUP BY AuditDWKey 
	) sub ON a.AuditDWKey = sub.AuditDWKey