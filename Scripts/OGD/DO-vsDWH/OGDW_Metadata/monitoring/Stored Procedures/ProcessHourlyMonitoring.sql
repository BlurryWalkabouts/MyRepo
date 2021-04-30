CREATE PROCEDURE [monitoring].[ProcessHourlyMonitoring]
AS
BEGIN

/* Load monitoring tables */

EXEC monitoring.LoadNewFailedFileImports

/* Send out all monitoring mails to relevant stakeholders */
/*
EXEC monitoring.CheckFailedSprocs @period = 2, @sendmail = 1
EXEC monitoring.CheckFailedJobs @period = 2, @sendmail = 1
EXEC monitoring.CheckFailedFileImports @period = 2, @sendmail = 1
EXEC monitoring.CheckDisabledForeignKeys @period = 2, @sendmail = 1

EXEC monitoring.CheckSetupViews @sendmail = 1
*/
END