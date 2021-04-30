-- de volgende regels roepen de andere deployment scripts aan
:r .\Script.PostDeployment2.sql 
--:r .\Script.PostDeployment3.sql 
:r .\Script.PostDeployment4.sql 

--/*
--Post-Deployment Script Template							
----------------------------------------------------------------------------------------
-- This file contains SQL statements that will be appended to the build script.		
-- Use SQLCMD syntax to include a file in the post-deployment script.			
-- Example:      :r .\myfile.sql								
-- Use SQLCMD syntax to reference a variable in the post-deployment script.		
-- Example:      :setvar TableName MyTable							
--               SELECT * FROM [$(TableName)]					
----------------------------------------------------------------------------------------


----r .\Debug\Bin\UT_OGDW_Staging_1.publish.sql

---- Restore mds to local DEFAULT (not named) instance
--USE [master]
--RESTORE DATABASE [$(MDS)] FROM  DISK = N'\\sqlman01\ogdw latest backups\mds.bak' WITH REPLACE, FILE = 1,  MOVE N'MDS' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MDS.mdf',  MOVE N'MDS_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MDS_log.ldf',  NOUNLOAD,  STATS = 5
--GO
--*/

--:setvar DatabaseName OGDW_Staging


----TEST1: 1 Incident inlezen.

----Create new AuditKey:
--DECLARE @AuditDWKey int 
----SET @auditdwkeycnt = (select max(auditdwkey)+1 from UT_OGDW_Metadata.log.audit)  --deze wordt vanzelf aangemaakt
---- log record aanmaken
--EXEC [OGDW_Metadata].[log].[LogNewAudit]  
--	@SourceDatabaseKey=15 ,
--	@SourceName = '1 testrecord.' ,
--	@SourceType = 'FILE',
--	@TargetName = '[FileImport].[Incidents]' ,
--	@AuditDWKey =  @AuditDWKey OUTPUT

--INSERT [$(DatabaseName)].FileImport.Incidents ([DurationAdjusted], [CardCreatedBy], [NumberOfDaysCurrent], [Department], [Closed], [OperatorName], [OperatorGroup], [TimeSpentFirstLine], [TimeSpentSecondLine], [Category], [ConfigurationID], [CreationDate], [ChangeDate], [IncidentDate], [ClosureDate], [TargetDate], [CompletionDate], [OnHoldDate], [Duration], [DurationOnHold], [CallerEmail], [ExternalNumber], [SlaAchieved], [DurationActual], [Completed], [TotalTime], [CallerGender], [Impact], [IsMajorIncident], [CustomerName], [IncidentDescription], [Supplier], [Line], [MajorIncident], [IncidentNumber], [CallerMobileNumber], [CallerName], [ObjectID], [Onhold], [CallerCity], [Priority], [ServiceWindow], [Sla], [SlaTargetDate], [SlaContract], [SlaLevel], [EntryType], [IncidentType], [StandardSolution], [Status], [Subcategory], [CallerTelephoneNumber], [CallerBranch], [CardChangedBy], [AuditDWKey]) 
--VALUES (14, N'Systeem_import_mail, ->', NULL, N'Controlling Vervoer1234567', 1, N'SERVICEDESK', N'SERVICEDESK', 0, 0, N'Basisdiensten', NULL, CAST(N'2016-01-14T14:59:39.000' AS DateTime), CAST(N'2016-01-21T15:04:12.000' AS DateTime), CAST(N'2016-01-14T14:59:00.000' AS DateTime), CAST(N'2016-01-21T15:04:00.000' AS DateTime), CAST(N'2016-01-21T15:50:00.000' AS DateTime), CAST(N'2016-01-14T15:13:00.000' AS DateTime), NULL, N'1 uur', 4431, N'Martijn.Nibbelink@gvb.nl', N'', N'Gehaald', 4445, 1, 0, N'Man', N'', 0, NULL, N'Aanvraag Ipad', NULL, N'Tweedelijns melding', NULL, N'M16010878', N'06-12048091', N'Nibbelink, Martijn', N'', 0, N'', N'Aanvraag', N'Standaard SLA service window', N'Aanvraag', CAST(N'2016-01-21T15:50:00.000' AS DateTime), N'SLA0007', N'Aanvraag', N'E-mail', N'Aanvraag', NULL, N'Afgemeld', N'Werkplekhardware', N'06-12345678', N'ALW', N'Querido, Thijs', @AuditDWKey)
--GO


----TEST2: Zelfde incident nog een keer inlezen.

----Create new AuditKey:
--DECLARE @AuditDWKey int 
----SET @auditdwkeycnt = (select max(auditdwkey)+1 from UT_OGDW_Metadata.log.audit)  --deze wordt vanzelf aangemaakt
---- log record aanmaken
--EXEC [OGDW_Metadata].[log].[LogNewAudit]  
--	@SourceDatabaseKey=15 ,
--	@SourceName = 'Nog een keer hetzelfde testrecord.' ,
--	@SourceType = 'FILE',
--	@TargetName = '[FileImport].[Incidents]' ,
--	@AuditDWKey =  @AuditDWKey OUTPUT

--INSERT [$(DatabaseName)].FileImport.Incidents ([DurationAdjusted], [CardCreatedBy], [NumberOfDaysCurrent], [Department], [Closed], [OperatorName], [OperatorGroup], [TimeSpentFirstLine], [TimeSpentSecondLine], [Category], [ConfigurationID], [CreationDate], [ChangeDate], [IncidentDate], [ClosureDate], [TargetDate], [CompletionDate], [OnHoldDate], [Duration], [DurationOnHold], [CallerEmail], [ExternalNumber], [SlaAchieved], [DurationActual], [Completed], [TotalTime], [CallerGender], [Impact], [IsMajorIncident], [CustomerName], [IncidentDescription], [Supplier], [Line], [MajorIncident], [IncidentNumber], [CallerMobileNumber], [CallerName], [ObjectID], [Onhold], [CallerCity], [Priority], [ServiceWindow], [Sla], [SlaTargetDate], [SlaContract], [SlaLevel], [EntryType], [IncidentType], [StandardSolution], [Status], [Subcategory], [CallerTelephoneNumber], [CallerBranch], [CardChangedBy], [AuditDWKey]) 
--VALUES (14, N'Systeem_import_mail, ->', NULL, N'Controlling Vervoer1234567', 1, N'SERVICEDESK', N'SERVICEDESK', 0, 0, N'Basisdiensten', NULL, CAST(N'2016-01-14T14:59:39.000' AS DateTime), CAST(N'2016-01-21T15:04:12.000' AS DateTime), CAST(N'2016-01-14T14:59:00.000' AS DateTime), CAST(N'2016-01-21T15:04:00.000' AS DateTime), CAST(N'2016-01-21T15:50:00.000' AS DateTime), CAST(N'2016-01-14T15:13:00.000' AS DateTime), NULL, N'1 uur', 4431, N'Martijn.Nibbelink@gvb.nl', N'', N'Gehaald', 4445, 1, 0, N'Man', N'', 0, NULL, N'Aanvraag Ipad', NULL, N'Tweedelijns melding', NULL, N'M16010878', N'06-12048091', N'Nibbelink, Martijn', N'', 0, N'', N'Aanvraag', N'Standaard SLA service window', N'Aanvraag', CAST(N'2016-01-21T15:50:00.000' AS DateTime), N'SLA0007', N'Aanvraag', N'E-mail', N'Aanvraag', NULL, N'Afgemeld', N'Werkplekhardware', N'06-12345678', N'ALW', N'Querido, Thijs', @AuditDWKey)
--GO



--/* UNIT TEST 3
--Een incident wordt aangepast zonder dat de changedate mee verandert
--waarom :
--Omdat we een beperkte set data binnen krijgen, en dus niet weten wanneer iemand echt 
--van department wisselt, misbruiken we hiervoor de incident changedate. Maar omdat 
--de incident door een dergelijke actie niet veranderd , verandert de changedate niet 
--en loopt de OGDW_AM vast 
--oorzaak
--primarky key violation op caller_department
--*/

---- counter creeert nieuwe auditdwkey 
--DECLARE @AuditDWKey int 
--EXEC [OGDW_Metadata].[log].[LogNewAudit]  
--	@SourceDatabaseKey=15 ,
--	@SourceName = 'Zelfde record met gewijzigd Department ' ,
--	@SourceType = 'FILE',
--	@TargetName = '[FileImport].[Incidents]' ,
--	@AuditDWKey =  @AuditDWKey OUTPUT

--INSERT [$(DatabaseName)].FileImport.Incidents ([DurationAdjusted], [CardCreatedBy], [NumberOfDaysCurrent], [Department], [Closed], [OperatorName], [OperatorGroup], [TimeSpentFirstLine], [TimeSpentSecondLine], [Category], [ConfigurationID], [CreationDate], [ChangeDate], [IncidentDate], [ClosureDate], [TargetDate], [CompletionDate], [OnHoldDate], [Duration], [DurationOnHold], [CallerEmail], [ExternalNumber], [SlaAchieved], [DurationActual], [Completed], [TotalTime], [CallerGender], [Impact], [IsMajorIncident], [CustomerName], [IncidentDescription], [Supplier], [Line], [MajorIncident], [IncidentNumber], [CallerMobileNumber], [CallerName], [ObjectID], [Onhold], [CallerCity], [Priority], [ServiceWindow], [Sla], [SlaTargetDate], [SlaContract], [SlaLevel], [EntryType], [IncidentType], [StandardSolution], [Status], [Subcategory], [CallerTelephoneNumber], [CallerBranch], [CardChangedBy], [AuditDWKey]) 
--VALUES (14, N'Systeem_import_mail, ->', NULL, N'Controlling Exploitatie BV', 1, N'SERVICEDESK', N'SERVICEDESK', 0, 0, N'Basisdiensten', NULL, CAST(N'2016-01-14T14:59:39.000' AS DateTime), CAST(N'2016-01-21T15:04:12.000' AS DateTime), CAST(N'2016-01-14T14:59:00.000' AS DateTime), CAST(N'2016-01-21T15:04:00.000' AS DateTime), CAST(N'2016-01-21T15:50:00.000' AS DateTime), CAST(N'2016-01-14T15:13:00.000' AS DateTime), NULL, N'1 uur', 4431, N'Martijn.Nibbelink@gvb.nl', N'', N'Gehaald', 4445, 1, 0, N'Man', N'', 0, NULL, N'Aanvraag Ipad', NULL, N'Tweedelijns melding', NULL, N'M16010878', N'06-12048091', N'Nibbelink, Martijn', N'', 0, N'', N'Aanvraag', N'Standaard SLA service window', N'Aanvraag', CAST(N'2016-01-21T15:50:00.000' AS DateTime), N'SLA0007', N'Aanvraag', N'E-mail', N'Aanvraag', NULL, N'Afgemeld', N'Werkplekhardware', N'06-12345678', N'ALW', N'Querido, Thijs', @AuditDWKey)
--GO


