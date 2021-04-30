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

-- post deployment script om test cases mee te nemen voor de file import

-- sdk 48 (FileImport wijzigingen) + 49 (FileImport incidenten)

/********************** incident ****************************/
-- Table : incident
insert into topdesk.incident (aanmelderafdelingid,aanmelderlokatieid,aanmeldertelefoon,aanmeldervestigingid,afgemeld,afhandelingstatusid,configuratieid,configuratieobjectid,dnoid,doorlooptijdid,gereed,persoonid,ref_dnocontractid,ref_domein,ref_impact,ref_soortmelding,ref_specificatie,soortbinnenkomstid,status,uidaanmk,uidwijzig,unid,dataanmk,datumaangemeld,datumafgemeld,datumafspraak,datumgereed,datwijzig,lijn1tijdbesteed,tijdbesteed,totaletijd,minutendoorlooptijd,dnostatus,korteomschrijving,datumafspraaksla,oplossingid,naam,ismajorincident,majorincidentid,vrijetekst1,servicewindowid,externnummer,aanmelderemail,onhold,onholdduration,onholddatum,priorityid,supplierid,aanmeldernaam,ref_operatordynanaam,ref_operatorgroup,adjusteddurationonhold,AuditDWKey,SourceDatabaseKey,impactid,incident_domeinid,incident_specid,operatorgroupid,operatorid,soortmeldingid)
    values ( 'AANMELDERAFDELINGID-XXXXXXXXXX-10003','AANMELDERLOKATIEID-XXXXXXXXXXX-10003','AANMELDERTELEFOON-XXXXXXXXXXXX-10003','AANMELDERVESTIGINGID-XXXXXXXXX-10003','1','AFHANDELINGSTATUSID-XXXXXXXXXX-10003','CONFIGURATIEID-XXXXXXXXXXXXXXX-10003','CONFIGURATIEOBJECTID-XXXXXXXXX-10003','DNOID-XXXXXXXXXXXXXXXXXXXXXXXX-10003','DOORLOOPTIJDID-XXXXXXXXXXXXXXX-10003','1','PERSOONID-XXXXXXXXXXXXXXXXXXXX-10003','REF_DNOCONTRACTID-XXXXXXXXXXXX-10003','REF_DOMEIN-XXXXXXXXXXXXXXXXXXX-10003','REF_IMPACT-XXXXXXXXXXXXXXXXXXX-10003','REF_SOORTMELDING-XXXXXXXXXXXXX-10003','REF_SPECIFICATIE-XXXXXXXXXXXXX-10003','SOORTBINNENKOMSTID-XXXXXXXXXXX-10003','1','UIDAANMK-XXXXXXXXXXXXXXXXXXXXX-10003','UIDWIJZIG-XXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','1','1','1','1','1','KORTEOMSCHRIJVING-XXXXXXXXXXXX-10003','2016-07-22 07:40:42.000','OPLOSSINGID-XXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','1','MAJORINCIDENTID-XXXXXXXXXXXXXX-10003','VRIJETEKST1-XXXXXXXXXXXXXXXXXX-10003','SERVICEWINDOWID-XXXXXXXXXXXXXX-10003','EXTERNNUMMER-XXXXXXXXXXXXXXXXX-10003','AANMELDEREMAIL-XXXXXXXXXXXXXXX-10003','1','1','2016-07-22 07:40:42.000','PRIORITYID-XXXXXXXXXXXXXXXXXXX-10003','SUPPLIERID-XXXXXXXXXXXXXXXXXXX-10003','AANMELDERNAAM-XXXXXXXXXXXXXXXX-10003','REF_OPERATORDYNANAAM-XXXXXXXXX-10003','REF_OPERATORGROUP-XXXXXXXXXXXX-10003','1','10003','49 ','IMPACTID-XXXXXXXXXXXXXXXXXXXXX-10003','INCIDENT_DOMEINID-XXXXXXXXXXXX-10003','INCIDENT_SPECID-XXXXXXXXXXXXXX-10003','OPERATORGROUPID-XXXXXXXXXXXXXX-10003','OPERATORID-XXXXXXXXXXXXXXXXXXX-10003','SOORTMELDINGID-XXXXXXXXXXXXXXX-10003' )
-- Table : persoon
insert into topdesk.persoon (geslacht,mobiel,plaats,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( '1','MOBIEL-XXXXXXXXXXXXXXXXXXXXXXX-10003','PLAATS-XXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )
-- Table : gebruiker
insert into topdesk.gebruiker (unid,naam,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )
-- Table : configuratie
insert into topdesk.configuratie (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )
-- Table : vestiging
insert into topdesk.vestiging (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey,plaats1)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ','PLAATS1-XXXXXXXXXXXXXXXXXXXXXX-10003' )
-- Table : afdeling
insert into topdesk.afdeling (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','49 ' )
-- Table : doorlooptijd
insert into topdesk.doorlooptijd (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','49 ' )
-- Table : soortbinnenkomst
insert into topdesk.soortbinnenkomst (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','49 ' )
-- Table : object
insert into topdesk.object (ref_aanspreekpuntid,ref_budgethouderid,ref_configuratieid,ref_groepid,ref_leverancier,ref_licentiesoortid,ref_plaats,ref_soort,ref_vestiging,statusid,type,unid,ref_ordernummer,ref_leasecontractnummer,ref_leaseperiode,ref_persoongroep,ref_aanschafdatum,ref_leaseaanvangsdatum,ref_leaseeinddatum,ref_aankoopbedrag,ref_leaseprijs,ref_restwaarde,ref_hostnaam,ref_ipadres,ref_type,ref_specificatie,ref_attentieid,ref_opmerking,ref_gebruiker,ref_persoon,ref_naam,ref_lokatie,ref_serienummer,AuditDWKey,SourceDatabaseKey,datwijzig)
    values ( 'REF_AANSPREEKPUNTID-XXXXXXXXXX-10003','REF_BUDGETHOUDERID-XXXXXXXXXXX-10003','REF_CONFIGURATIEID-XXXXXXXXXXX-10003','REF_GROEPID-XXXXXXXXXXXXXXXXXX-10003','REF_LEVERANCIER-XXXXXXXXXXXXXX-10003','REF_LICENTIESOORTID-XXXXXXXXXX-10003','REF_PLAATS-XXXXXXXXXXXXXXXXXXX-10003','REF_SOORT-XXXXXXXXXXXXXXXXXXXX-10003','REF_VESTIGING-XXXXXXXXXXXXXXXX-10003','STATUSID-XXXXXXXXXXXXXXXXXXXXX-10003','TYPE-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','REF_ORDERNUMMER-XXXXXXXXXXXXXX-10003','REF_LEASECONTRACTNUMMER-XXXXXX-10003','1','REF_PERSOONGROEP-XXXXXXXXXXXXX-10003','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','123,45','123,45','123,45','REF_HOSTNAAM-XXXXXXXXXXXXXXXXX-10003','REF_IPADRES-XXXXXXXXXXXXXXXXXX-10003','REF_TYPE-XXXXXXXXXXXXXXXXXXXXX-10003','REF_SPECIFICATIE-XXXXXXXXXXXXX-10003','REF_ATTENTIEID-XXXXXXXXXXXXXXX-10003','REF_OPMERKING-XXXXXXXXXXXXXXXX-10003','REF_GEBRUIKER-XXXXXXXXXXXXXXXX-10003','REF_PERSOON-XXXXXXXXXXXXXXXXXX-10003','REF_NAAM-XXXXXXXXXXXXXXXXXXXXX-10003','REF_LOKATIE-XXXXXXXXXXXXXXXXXX-10003','REF_SERIENUMMER-XXXXXXXXXXXXXX-10003','10003','49 ','2016-07-22 07:40:42.000' )
-- Table : priority
insert into topdesk.priority (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','49 ' )
-- Table : servicewindow
insert into topdesk.servicewindow (unid,naam,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )
-- Table : dnolink
insert into topdesk.dnolink (unid,ref_naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','REF_NAAM-XXXXXXXXXXXXXXXXXXXXX-10003','10003','49 ' )
-- Table : dnocontract
insert into topdesk.dnocontract (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )
-- Table : dnoniveau
insert into topdesk.dnoniveau (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )
-- Table : oplossingen
insert into topdesk.oplossingen (unid,korteomschrijving,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','KORTEOMSCHRIJVING-XXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )
-- Table : afhandelingstatus
insert into topdesk.afhandelingstatus (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','49 ' )
-- Table : leverancier
insert into topdesk.leverancier (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','49 ' )


/********************** Change ****************************/
-- Table : Change
insert into topdesk.Change (aanmelderafdelingid,aanmelderemail,aanmelderlokatieid,aanmeldertelefoon,aanmeldervestigingid,briefdescription,calc_type_authdate,calc_type_finaldate,calc_type_impldate,calldate,categoryid,changetype,closed,closeddate,completed,completeddate,currentphase,dataanmk,datwijzig,finaldate,externalnumber,impactid,incidentid,isurgent,managerid,number,objectid,operatorgroupid,plannedauthdate,plannedfinaldate,plannedimpldate,implementationdate,rejecteddate,authorizationdate,started,starteddate,statusid,subcategoryid,submitdate,templateid,timetaken,typeid,uidaanmk,uidwijzig,unid,withevaluation,vrijelogisch2,vrijeopzoek3,plannedstartdate,canceledbypersonid,canceledbyoperatorid,canceldate,priorityid,rejected,pro_rejecteddate,aanmeldernaam,AuditDWKey,SourceDatabaseKey)
    values ( 'AANMELDERAFDELINGID-XXXXXXXXXX-10003','AANMELDEREMAIL-XXXXXXXXXXXXXXX-10003','AANMELDERLOKATIEID-XXXXXXXXXXX-10003','AANMELDERTELEFOON-XXXXXXXXXXXX-10003','AANMELDERVESTIGINGID-XXXXXXXXX-10003','BRIEFDESCRIPTION-XXXXXXXXXXXXX-10003','1','1','1','2016-07-22 07:40:42.000','CATEGORYID-XXXXXXXXXXXXXXXXXXX-10003','1','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','EXTERNALNUMBER-XXXXXXXXXXXXXXX-10003','IMPACTID-XXXXXXXXXXXXXXXXXXXXX-10003','INCIDENTID-XXXXXXXXXXXXXXXXXXX-10003','1','MANAGERID-XXXXXXXXXXXXXXXXXXXX-10003','NUMBER-XXXXXXXXXXXXXXXXXXXXXXX-10003','OBJECTID-XXXXXXXXXXXXXXXXXXXXX-10003','OPERATORGROUPID-XXXXXXXXXXXXXX-10003','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','2016-07-22 07:40:42.000','1','2016-07-22 07:40:42.000','STATUSID-XXXXXXXXXXXXXXXXXXXXX-10003','SUBCATEGORYID-XXXXXXXXXXXXXXXX-10003','2016-07-22 07:40:42.000','TEMPLATEID-XXXXXXXXXXXXXXXXXXX-10003','1','TYPEID-XXXXXXXXXXXXXXXXXXXXXXX-10003','UIDAANMK-XXXXXXXXXXXXXXXXXXXXX-10003','UIDWIJZIG-XXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','1','1','VRIJEOPZOEK3-XXXXXXXXXXXXXXXXX-10003','2016-07-22 07:40:42.000','CANCELEDBYPERSONID-XXXXXXXXXXX-10003','CANCELEDBYOPERATORID-XXXXXXXXX-10003','2016-07-22 07:40:42.000','PRIORITYID-XXXXXXXXXXXXXXXXXXX-10003','1','2016-07-22 07:40:42.000','AANMELDERNAAM-XXXXXXXXXXXXXXXX-10003','10003','48 ' )
-- Table : Actiedoor
insert into topdesk.Actiedoor (loginnaamtopdeskid,unid,vestigingid,naam,email,datwijzig,tasloginnaam,ref_dynanaam,AuditDWKey,SourceDatabaseKey,achternaam,tussenvoegsel,voornaam)
    values ( 'LOGINNAAMTOPDESKID-XXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','VESTIGINGID-XXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','EMAIL-XXXXXXXXXXXXXXXXXXXXXXXX-10003','2016-07-22 07:40:42.000','TASLOGINNAAM-XXXXXXXXXXXXXXXXX-10003','REF_DYNANAAM-XXXXXXXXXXXXXXXXX-10003','10003','48 ','ACHTERNAAM-XXXXXXXXXXXXXXXXXXX-10003','TUSSENVOEGSEL-XXXXXXXXXXXXXXXX-10003','VOORNAAM-XXXXXXXXXXXXXXXXXXXXX-10003' )
-- Table : classificatie
insert into topdesk.classificatie (naam,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','48 ' )
-- Table : Wijziging_impact
insert into topdesk.Wijziging_impact (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','48 ' )
-- Table : change_priority
insert into topdesk.change_priority (unid,naam,AuditDWKey,SourceDatabaseKey)
    values ( 'UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','48 ' )
-- Table : Wijziging_impact
insert into topdesk.Wijziging_impact (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','48 ' )
-- Table : Wijzigingstatus
insert into topdesk.Wijzigingstatus (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','48 ' )
-- Table : change_template
insert into topdesk.change_template (briefdescription,unid,AuditDWKey,datwijzig,SourceDatabaseKey)
    values ( 'BRIEFDESCRIPTION-XXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','2016-07-22 07:40:42.000','48 ' )
-- Table : Wbaanvraagtype
insert into topdesk.Wbaanvraagtype (naam,unid,AuditDWKey,SourceDatabaseKey)
    values ( 'NAAM-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','UNID-XXXXXXXXXXXXXXXXXXXXXXXXX-10003','10003','48 ' )
