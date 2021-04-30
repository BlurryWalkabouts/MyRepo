CREATE PROCEDURE [monitoring].[ProcessEveningMonitoring]
AS
BEGIN

/* Load monitoring tables */

EXEC monitoring.LoadNewReportExecutions
EXEC monitoring.LoadReportServerCatalog

/* Send out all monitoring mails to relevant stakeholders */
/*
EXEC monitoring.CheckOpenIncidents @recent = 1, @sendmail = 1
EXEC monitoring.CheckOpenChanges @recent = 1, @sendmail = 1
*/
END