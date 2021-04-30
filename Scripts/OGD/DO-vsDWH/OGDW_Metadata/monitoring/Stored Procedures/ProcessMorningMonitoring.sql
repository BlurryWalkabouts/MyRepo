CREATE PROCEDURE [monitoring].[ProcessMorningMonitoring]
AS
BEGIN

/* Load monitoring tables */

EXEC monitoring.LoadDatabaseRowsCount 'Incident'
EXEC monitoring.LoadDatabaseRowsCount 'Change'
EXEC monitoring.LoadDatabaseRowsCount 'ChangeActivity'
EXEC monitoring.LoadDatabaseRowsCount 'Problem'

/* Voorlopig nog uitgeschakeld, omdat het nog niet voldoende getest is
TRUNCATE TABLE monitoring.RowsNotConnecting
EXEC monitoring.LoadRowsNotConnecting '[$(OGDW_Archive)]', 'TOPdesk'
EXEC monitoring.LoadRowsNotConnecting '[$(OGDW_Archive)]', 'fileimport'
EXEC monitoring.LoadRowsNotConnecting '[$(LIFT_Archive)]', 'dbo'
*/

/* Send out all monitoring mails to relevant stakeholders */
/*
EXEC monitoring.CheckXMLImport @sdk = 318, @folder = 'GVBLokaal', @sendmail = 1
EXEC monitoring.CheckXMLImport @sdk = 324, @folder = 'Beweging3_SFTP', @sendmail = 1

DECLARE @lift_staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))
EXEC monitoring.CheckStagingVsArchive @dbStaging = '[$(LIFT_Staging)]', @schemaStaging = @lift_staging_schema, @dbArchive = '[$(LIFT_Archive)]', @schemaArchive = 'dbo', @sendmail = 1
EXEC monitoring.CheckStagingVsArchive @dbStaging = '[$(OGDW_Staging)]', @schemaStaging = 'TOPdesk', @dbArchive = '[$(OGDW_Archive)]', @schemaArchive = 'TOPdesk', @sendmail = 1

--EXEC monitoring.CheckLIFTArchiveDiffs @recipients = ''
--EXEC monitoring.CheckOGDWArchiveDiffs @recipients = ''

EXEC monitoring.CheckMissingAnywhereMappings @sendmail = 1
EXEC monitoring.CheckMissingCustomers @sendmail = 1
EXEC monitoring.CheckMissingCustomerKeys @sendmail = 1
EXEC monitoring.CheckMissingStatuses @sendmail = 1
EXEC monitoring.CheckMissingTranslations @sendmail = 1
--EXEC monitoring.CheckStagingJobs @sendmail = 1

EXEC monitoring.OverviewCurrentRecords @facttable = 'Incident', @sendmail = 1
EXEC monitoring.OverviewCurrentRecords @facttable = 'Change', @sendmail = 1
EXEC monitoring.OverviewCurrentRecords @facttable = 'ChangeActivity', @sendmail = 1
EXEC monitoring.OverviewCurrentRecords @facttable = 'Problem', @sendmail = 1
EXEC monitoring.CheckDatabaseRowsCount @sendmail = 1

EXEC monitoring.CheckIncorrectCallers @sendmail = 1
*/
END