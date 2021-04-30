CREATE PROCEDURE [Load].[LoadFactPlanning]
(
	@WriteLog bit = 1
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM Fact.Planning

PRINT 'Inserting data into Fact.Planning'

;WITH d AS (SELECT [Date] FROM Dim.[Date] WHERE [DayOfWeek] NOT IN (6,7))

-- Planningtabel aangevuld met berekende einddatum van een uitzondering op een standaardwerklast
, PlanningWithEndDate AS
(
SELECT -- Planning van persoonsvoordrachten 
	unid = assignmentid -- is gelijk aan de unid uit tabel dbo.voordracht
	, startdatum = startdate
	, aantal = amount
	, einddatum = LAG(startdate) OVER (PARTITION BY assignmentid ORDER BY startdate DESC)
FROM
	[archive].planning_assignment
UNION ALL
SELECT -- Planning van activiteitgroepvoordrachten
	unid = activiteitgroep_voordrachtid -- is gelijk aan de unid uit tabel dbo.activiteitgroep_voordracht
	, startdatum
	, aantal
	, einddatum = LAG(startdatum) OVER (PARTITION BY activiteitgroep_voordrachtid ORDER BY startdatum DESC)
FROM
	[archive].activiteitgroep_voordracht_planning
UNION ALL
SELECT -- Planning van taakgroepvoordrachten
	unid = task_assignmentid -- is gelijk aan de unid uit tabel dbo.taakvoordracht
	, startdatum = startdate
	, aantal = amount
	, einddatum = LAG(startdate) OVER (PARTITION BY task_assignmentid ORDER BY startdate DESC)
FROM
	[archive].planning_task_assignment
)

INSERT INTO
	Fact.Planning
	(
	NominationKey
	, PlanningDate
	, WorkloadWeeklyDefault
	, WorkloadWeekly
	, WorkloadWeeklyAdjusted
	, EstimatedWorkloadDaily
	, EstimatedPlannedTurnover
	)
SELECT
	NominationKey = n.NominationKey
	, PlanningDate = d.[Date]
	, WorkloadWeeklyDefault = CAST(WorkloadWeekly AS decimal(9,2))
	, WorkloadWeekly = CAST(COALESCE(p.aantal, n.WorkloadWeekly) AS decimal(9,2))
	, WorkloadWeeklyAdjusted = CASE WHEN p.aantal IS NOT NULL THEN 1 ELSE 0 END
	, EstimatedWorkloadDaily = CAST(COALESCE(p.aantal, n.WorkloadWeekly) / 5.0 AS decimal(9,2))
	, EstimatedPlannedTurnover = n.HourlyRate * CAST(COALESCE(p.aantal, n.WorkloadWeekly) / 5.0 AS money)
FROM
	Dim.Nomination n
	INNER JOIN d ON d.[Date] >= n.PlanningStartDate AND d.[Date] <= n.PlanningEndDate
	LEFT OUTER JOIN PlanningWithEndDate p ON p.unid = n.unid AND p.startdatum <= d.[Date] AND (einddatum > d.[Date] OR einddatum IS NULL)
WHERE 1=1
	AND n.PlanningEndDate > '2015-12-31'
	AND n.NominationType <> 'Public Task'

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END
