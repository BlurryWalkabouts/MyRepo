/*
Missing Index Details from dashboard.finance.HoursPerPhase.sql - ogd-replica-001013.database.windows.net.lift (sys_gert-jans@ogd.nl (126))
The Query Processor estimates that implementing the following index could improve the query cost by 49.2082%.
*/

USE [lift]
GO
CREATE NONCLUSTERED INDEX [IX_assignment_hour_assignmentByDate]
ON [dbo].[assignment_hour] ([assignmentid],[datum])
INCLUDE ([verwerkt_factuur],[seen_by_invoice_id],[hourtypeid],[seconds])
GO
USE [lift]
GO
CREATE NONCLUSTERED INDEX [IX_ProjectStatus]
ON [dbo].[project] ([status])
INCLUDE ([unid],[projectgroepid],[projectnaam])
GO
USE [lift]
GO
CREATE NONCLUSTERED INDEX [IX_voordracht_StatusStartEnd]
ON [dbo].[voordracht] ([status],[startdatum],[einddatum])
INCLUDE ([unid],[projectid],[uurprijs],[werklast],[employeeid])
GO
CREATE NONCLUSTERED INDEX [IX_voordracht_StatusStartEnd] ON [dbo].[voordracht]
(
	[status] ASC,
	[startdatum] ASC,
	[einddatum] ASC
)
INCLUDE ( 	[unid],
	[projectid],
	[uurprijs],
	[werklast],
	[employeeid]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO