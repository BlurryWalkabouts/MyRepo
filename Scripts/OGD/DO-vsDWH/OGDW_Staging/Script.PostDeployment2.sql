/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- post deployment script om test cases mee te nemen voor de DB import


-- sdk = 1 (MSSQL)

/********************** Auditdwkey ****************************/
	if	not exists
	(select distinct auditdwkey from OGDW_Metadata.log.Audit where AuditDWKey=1)
	
	BEGIN

	SET IDENTITY_INSERT OGDW_Metadata.log.Audit  ON
	insert into OGDW_Metadata.log.Audit 
	(AuditDWKey,BatchDWKey,SourceDatabaseKey,SourceName,SourceType,TargetName,ServerExecutionID,ExecutionID,PackageGUID,PackageVersionGUID,Status,DWDateCreated,StagingSuccessful,StagingEndTime,StagingRowsProcessed,deleted,AMDateImported)
	values(1,1,1,'TB','MSSQL','TB',0,null,null,null,0,'2015-01-30 16:57:10.427',0,NULL,0,0,null)
	SET IDENTITY_INSERT OGDW_Metadata.log.Audit  OFF


/********************** Incident ****************************/
-- Table : incident
insert into topdesk.incident (aanmelderafdelingid,aanmelderlokatieid,aanmeldertelefoon,aanmeldervestigingid,afgemeld,afhandelingstatusid,configuratieid,configuratieobjectid,dnoid,doorlooptijdid,gereed,persoonid,ref_dnocontractid,ref_domein,ref_impact,ref_soortmelding,ref_specificatie,soortbinnenkomstid,status,uidaanmk,uidwijzig,unid,dataanmk,datumaangemeld,datumafgemeld,datumafspraak,datumgereed,datwijzig,lijn1tijdbesteed,tijdbesteed,totaletijd,minutendoorlooptijd,dnostatus,korteomschrijving,datumafspraaksla,oplossingid,naam,ismajorincident,majorincidentid,vrijetekst1,servicewindowid,externnummer,aanmelderemail,onhold,onholdduration,onholddatum,priorityid,supplierid,aanmeldernaam,ref_operatordynanaam,ref_operatorgroup,adjusteddurationonhold,AuditDWKey,SourceDatabaseKey,impactid,incident_domeinid,incident_specid,operatorgroupid,operatorid,soortmeldingid)
    values ( 'AANMELDERAFDELINGID-XXXXXXXXXX-00001','AANMELDERLOKATIEID-XXXXXXXXXXX-00001','AANMELDERTELEFOON-XXXXXXXXXXXX-00001','AANMELDERVESTIGINGID-XXXXXXXXX-00001','1','AFHANDELINGSTATUSID-XXXXXXXXXX-00001','CONFIGURATIEID-XXXXXXXXXXXXXXX-00001','CONFIGURATIEOBJECTID-XXXXXXXXX-00001','DNOID-XXXXXXXXXXXXXXXXXXXXXXXX-00001','DOORLOOPTIJDID-XXXXXXXXXXXXXXX-00001','1','PERSOONID-XXXXXXXXXXXXXXXXXXXX-00001','REF_DNOCONTRACTID-XXXXXXXXXXXX-00001','REF_DOMEIN-XXXXXXXXXXXXXXXXXXX-00001','REF_IMPACT-XXXXXXXXXXXXXXXXXXX-00001','REF_SOORTMELDING-XXXXXXXXXXXXX-00001','REF_SPECIFICATIE-XXXXXXXXXXXXX-00001','SOORTBINNENKOMSTID-XXXXXXXXXXX-00001','1','UIDAANMK-XXXXXXXXXXXXXXXXXXXXX-00001','UIDWIJZIG-XXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','1','1','1','1','1','KORTEOMSCHRIJVING-XXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','OPLOSSINGID-XXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','MAJORINCIDENTID-XXXXXXXXXXXXXX-00001','VRIJETEKST1-XXXXXXXXXXXXXXXXXX-00001','SERVICEWINDOWID-XXXXXXXXXXXXXX-00001','EXTERNNUMMER-XXXXXXXXXXXXXXXXX-00001','AANMELDEREMAIL-XXXXXXXXXXXXXXX-00001','1','1','2016-07-22 07:40:42.000','PRIORITYID-XXXXXXXXXXXXXXXXXXX-00001','SUPPLIERID-XXXXXXXXXXXXXXXXXXX-00001','AANMELDERNAAM-XXXXXXXXXXXXXXXX-00001','REF_OPERATORDYNANAAM-XXXXXXXXX-00001','REF_OPERATORGROUP-XXXXXXXXXXXX-00001','1','1','1','IMPACTID-XXXXXXXXXXXXXXXXXXXXX-00001','INCIDENT_DOMEINID-XXXXXXXXXXXX-00001','INCIDENT_SPECID-XXXXXXXXXXXXXX-00001','OPERATORGROUPID-XXXXXXXXXXXXXX-00001','OPERATORID-XXXXXXXXXXXXXXXXXXX-00001','SOORTMELDINGID-XXXXXXXXXXXXXXX-00001' )
-- Table : persoon
insert into topdesk.persoon (geslacht,mobiel,plaats,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( '1','MOBIEL-XXXXXXXXXXXXXXXXXXXXXXX-00001','PLAATS-XXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : gebruiker
insert into topdesk.gebruiker (unid,naam,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : configuratie
insert into topdesk.configuratie (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : vestiging
insert into topdesk.vestiging (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey,plaats1)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1','PLAATS1-XXXXXXXXXXXXXXXXXXXXXX-00001' )
-- Table : afdeling
insert into topdesk.afdeling (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : doorlooptijd
insert into topdesk.doorlooptijd (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : soortbinnenkomst
insert into topdesk.soortbinnenkomst (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : object
insert into topdesk.object (ref_aanspreekpuntid,ref_budgethouderid,ref_configuratieid,ref_groepid,ref_leverancier,ref_licentiesoortid,ref_plaats,ref_soort,ref_vestiging,statusid,type,unid,ref_ordernummer,ref_leasecontractnummer,ref_leaseperiode,ref_persoongroep,ref_aanschafdatum,ref_leaseaanvangsdatum,ref_leaseeinddatum,ref_aankoopbedrag,ref_leaseprijs,ref_restwaarde,ref_hostnaam,ref_ipadres,ref_type,ref_specificatie,ref_attentieid,ref_opmerking,ref_gebruiker,ref_persoon,ref_naam,ref_lokatie,ref_serienummer,AuditDWKey,SourceDatabaseKey,datwijzig)
    values ( 'REF_AANSPREEKPUNTID-XXXXXXXXXX-00001','REF_BUDGETHOUDERID-XXXXXXXXXXX-00001','REF_CONFIGURATIEID-XXXXXXXXXXX-00001','REF_GROEPID-XXXXXXXXXXXXXXXXXX-00001','REF_LEVERANCIER-XXXXXXXXXXXXXX-00001','REF_LICENTIESOORTID-XXXXXXXXXX-00001','REF_PLAATS-XXXXXXXXXXXXXXXXXXX-00001','REF_SOORT-XXXXXXXXXXXXXXXXXXXX-00001','REF_VESTIGING-XXXXXXXXXXXXXXXX-00001','STATUSID-XXXXXXXXXXXXXXXXXXXXX-00001','TYPE-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','REF_ORDERNUMMER-XXXXXXXXXXXXXX-00001','REF_LEASECONTRACTNUMMER-XXXXXX-00001','1','REF_PERSOONGROEP-XXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','123,45','123,45','123,45','REF_HOSTNAAM-XXXXXXXXXXXXXXXXX-00001','REF_IPADRES-XXXXXXXXXXXXXXXXXX-00001','REF_TYPE-XXXXXXXXXXXXXXXXXXXXX-00001','REF_SPECIFICATIE-XXXXXXXXXXXXX-00001','REF_ATTENTIEID-XXXXXXXXXXXXXXX-00001','REF_OPMERKING-XXXXXXXXXXXXXXXX-00001','REF_GEBRUIKER-XXXXXXXXXXXXXXXX-00001','REF_PERSOON-XXXXXXXXXXXXXXXXXX-00001','REF_NAAM-XXXXXXXXXXXXXXXXXXXXX-00001','REF_LOKATIE-XXXXXXXXXXXXXXXXXX-00001','REF_SERIENUMMER-XXXXXXXXXXXXXX-00001','1','1','2016-07-22 07:40:42.000' )
-- Table : priority
insert into topdesk.priority (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : servicewindow
insert into topdesk.servicewindow (unid,naam,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : dnolink
insert into topdesk.dnolink (unid,ref_naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','REF_NAAM-XXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : dnocontract
insert into topdesk.dnocontract (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : dnoniveau
insert into topdesk.dnoniveau (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : oplossingen
insert into topdesk.oplossingen (unid,korteomschrijving,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','KORTEOMSCHRIJVING-XXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : afhandelingstatus
insert into topdesk.afhandelingstatus (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : leverancier
insert into topdesk.leverancier (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )

/********************** change ****************************/
-- Table : Change
insert into topdesk.Change (aanmelderafdelingid,aanmelderemail,aanmelderlokatieid,aanmeldertelefoon,aanmeldervestigingid,briefdescription,calc_type_authdate,calc_type_finaldate,calc_type_impldate,calldate,categoryid,changetype,closed,closeddate,completed,completeddate,currentphase,dataanmk,datwijzig,finaldate,externalnumber,impactid,incidentid,isurgent,managerid,number,objectid,operatorgroupid,plannedauthdate,plannedfinaldate,plannedimpldate,implementationdate,rejecteddate,authorizationdate,started,starteddate,statusid,subcategoryid,submitdate,templateid,timetaken,typeid,uidaanmk,uidwijzig,unid,withevaluation,vrijelogisch2,vrijeopzoek3,plannedstartdate,canceledbypersonid,canceledbyoperatorid,canceldate,priorityid,rejected,pro_rejecteddate,aanmeldernaam,AuditDWKey,SourceDatabaseKey)
    values ( 'AANMELDERAFDELINGID-XXXXXXXXXX-00001','AANMELDEREMAIL-XXXXXXXXXXXXXXX-00001','AANMELDERLOKATIEID-XXXXXXXXXXX-00001','AANMELDERTELEFOON-XXXXXXXXXXXX-00001','AANMELDERVESTIGINGID-XXXXXXXXX-00001','BRIEFDESCRIPTION-XXXXXXXXXXXXX-00001','1','1','1','2016-07-22 07:40:42.000','CATEGORYID-XXXXXXXXXXXXXXXXXXX-00001','1','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','EXTERNALNUMBER-XXXXXXXXXXXXXXX-00001','IMPACTID-XXXXXXXXXXXXXXXXXXXXX-00001','INCIDENTID-XXXXXXXXXXXXXXXXXXX-00001','1','MANAGERID-XXXXXXXXXXXXXXXXXXXX-00001','NUMBER-XXXXXXXXXXXXXXXXXXXXXXX-00001','OBJECTID-XXXXXXXXXXXXXXXXXXXXX-00001','OPERATORGROUPID-XXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','STATUSID-XXXXXXXXXXXXXXXXXXXXX-00001','SUBCATEGORYID-XXXXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','TEMPLATEID-XXXXXXXXXXXXXXXXXXX-00001','1','TYPEID-XXXXXXXXXXXXXXXXXXXXXXX-00001','UIDAANMK-XXXXXXXXXXXXXXXXXXXXX-00001','UIDWIJZIG-XXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1','VRIJEOPZOEK3-XXXXXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','CANCELEDBYPERSONID-XXXXXXXXXXX-00001','CANCELEDBYOPERATORID-XXXXXXXXX-00001','2016-07-22 07:40:42.000','PRIORITYID-XXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','AANMELDERNAAM-XXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : Actiedoor
insert into topdesk.Actiedoor (loginnaamtopdeskid,unid,vestigingid,naam,email,datwijzig,tasloginnaam,ref_dynanaam,AuditDWKey,SourceDatabaseKey,achternaam,tussenvoegsel,voornaam)
    values ( 'LOGINNAAMTOPDESKID-XXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','VESTIGINGID-XXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','EMAIL-XXXXXXXXXXXXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','TASLOGINNAAM-XXXXXXXXXXXXXXXXX-00001','REF_DYNANAAM-XXXXXXXXXXXXXXXXX-00001','1','1','ACHTERNAAM-XXXXXXXXXXXXXXXXXXX-00001','TUSSENVOEGSEL-XXXXXXXXXXXXXXXX-00001','VOORNAAM-XXXXXXXXXXXXXXXXXXXXX-00001' )
-- Table : classificatie
insert into topdesk.classificatie (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : Wijziging_impact
insert into topdesk.Wijziging_impact (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : change_priority
insert into topdesk.change_priority (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : Wijziging_impact
insert into topdesk.Wijziging_impact (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : Wijzigingstatus
insert into topdesk.Wijzigingstatus (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : change_template
insert into topdesk.change_template (briefdescription,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'BRIEFDESCRIPTION-XXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','1' )
-- Table : Wbaanvraagtype
insert into topdesk.Wbaanvraagtype (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )

	
/********************** probleem ****************************/
-- Table : Change
insert into topdesk.Change (aanmelderafdelingid,aanmelderemail,aanmelderlokatieid,aanmeldertelefoon,aanmeldervestigingid,briefdescription,calc_type_authdate,calc_type_finaldate,calc_type_impldate,calldate,categoryid,changetype,closed,closeddate,completed,completeddate,currentphase,dataanmk,datwijzig,finaldate,externalnumber,impactid,incidentid,isurgent,managerid,number,objectid,operatorgroupid,plannedauthdate,plannedfinaldate,plannedimpldate,implementationdate,rejecteddate,authorizationdate,started,starteddate,statusid,subcategoryid,submitdate,templateid,timetaken,typeid,uidaanmk,uidwijzig,unid,withevaluation,vrijelogisch2,vrijeopzoek3,plannedstartdate,canceledbypersonid,canceledbyoperatorid,canceldate,priorityid,rejected,pro_rejecteddate,aanmeldernaam,AuditDWKey,SourceDatabaseKey)
    values ( 'AANMELDERAFDELINGID-XXXXXXXXXX-00001','AANMELDEREMAIL-XXXXXXXXXXXXXXX-00001','AANMELDERLOKATIEID-XXXXXXXXXXX-00001','AANMELDERTELEFOON-XXXXXXXXXXXX-00001','AANMELDERVESTIGINGID-XXXXXXXXX-00001','BRIEFDESCRIPTION-XXXXXXXXXXXXX-00001','1','1','1','2016-07-22 07:40:42.000','CATEGORYID-XXXXXXXXXXXXXXXXXXX-00001','1','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','EXTERNALNUMBER-XXXXXXXXXXXXXXX-00001','IMPACTID-XXXXXXXXXXXXXXXXXXXXX-00001','INCIDENTID-XXXXXXXXXXXXXXXXXXX-00001','1','MANAGERID-XXXXXXXXXXXXXXXXXXXX-00001','NUMBER-XXXXXXXXXXXXXXXXXXXXXXX-00001','OBJECTID-XXXXXXXXXXXXXXXXXXXXX-00001','OPERATORGROUPID-XXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','STATUSID-XXXXXXXXXXXXXXXXXXXXX-00001','SUBCATEGORYID-XXXXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','TEMPLATEID-XXXXXXXXXXXXXXXXXXX-00001','1','TYPEID-XXXXXXXXXXXXXXXXXXXXXXX-00001','UIDAANMK-XXXXXXXXXXXXXXXXXXXXX-00001','UIDWIJZIG-XXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1','VRIJEOPZOEK3-XXXXXXXXXXXXXXXXX-00001','2016-07-22 07:40:42.000','CANCELEDBYPERSONID-XXXXXXXXXXX-00001','CANCELEDBYOPERATORID-XXXXXXXXX-00001','2016-07-22 07:40:42.000','PRIORITYID-XXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','AANMELDERNAAM-XXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : probleem_doorlooptijd
insert into topdesk.probleem_doorlooptijd (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : probleem_impact
insert into topdesk.probleem_impact (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : problem_priority
insert into topdesk.problem_priority (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : probleem_oorzaak
insert into topdesk.probleem_oorzaak (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : probleem_categorie
insert into topdesk.probleem_categorie (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : archiefreden
insert into topdesk.archiefreden (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : probleem_status
insert into topdesk.probleem_status (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : probleem_categorie
insert into topdesk.probleem_categorie (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : vrijeopzoekvelden
insert into topdesk.vrijeopzoekvelden (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )
-- Table : problem_urgency
insert into topdesk.problem_urgency (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )

	/********************** changeActivity ****************************/
-- Table : changeActivity
insert into topdesk.changeActivity (approved,approveddate,briefdescription,categoryid,changeid,currentplantimetaken,dataanmk,datwijzig,number,operatorgroupid,operatorid,originalplantimetaken,changephase,plannedfinaldate,plannedstartdate,rejected,rejecteddate,resolved,resolveddate,skipped,skippeddate,started,starteddate,status,subcategoryid,timetaken,uidaanmk,uidwijzig,unid,activitystatusid,maystart,ref_change_brief_description,AuditDWKey,SourceDatabaseKey,activitytemplateid)
    values ( '1','2016-07-22 07:40:42.000','BRIEFDESCRIPTION-XXXXXXXXXXXXX-00001','CATEGORYID-XXXXXXXXXXXXXXXXXXX-00001','CHANGEID-XXXXXXXXXXXXXXXXXXXXX-00001','1','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','NUMBER-XXXXXXXXXXXXXXXXXXXXXXX-00001','OPERATORGROUPID-XXXXXXXXXXXXXX-00001','OPERATORID-XXXXXXXXXXXXXXXXXXX-00001','1','1','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','1','SUBCATEGORYID-XXXXXXXXXXXXXXXX-00001','1','UIDAANMK-XXXXXXXXXXXXXXXXXXXXX-00001','UIDWIJZIG-XXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','ACTIVITYSTATUSID-XXXXXXXXXXXXX-00001','1','REF_CHANGE_BRIEF_DESCRIPTION-X-00001','1','1','ACTIVITYTEMPLATEID-XXXXXXXXXXX-00001' )
-- Table : change_activitytemplate
insert into topdesk.change_activitytemplate (number,unid,AuditDWKey,SourceDatabaseKey,operatorgroupid,duration_in_minutes,duration_in_workdays)
    values ( 'NUMBER-XXXXXXXXXXXXXXXXXXXXXXX-00001','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1','OPERATORGROUPID-XXXXXXXXXXXXXX-00001','1','1' )
-- Table : changeactivity_status
insert into topdesk.changeactivity_status (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-00001','1','1' )

		END