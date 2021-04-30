CREATE PROCEDURE [Load].[LoadFactPlanningHistory]
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

DECLARE @reference_date DATE; -- Datum waarop een bepaalde planning geldig is (snapshot van de geschiedenis op een bepaalde dag)
DECLARE @planning_date DATE; -- Datum waar een planning betrekking op heeft (voorlopig gelijk aan de reference date)

-- Start logging
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM Fact.PlanningHistory

PRINT 'Inserting data into Fact.PlanningHistory'

-- De cursor ReferenceDate gaat alle datums vanaf 1-1-2017 af
DECLARE ReferenceDate CURSOR FOR
SELECT [Date] FROM Dim.[Date] WHERE [DayOfWeek] NOT IN (6,7) And [Date] >= '2017-01-01'
                                                             And [Date] <= DATEADD(d, -1, GETDATE())
-- Haal de eerste datum uit de cursor
OPEN ReferenceDate;
FETCH NEXT FROM ReferenceDate INTO @reference_date;
SET @planning_date = @reference_date;

WHILE @@FETCH_STATUS = 0
BEGIN
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
        --FIXME the system_time approach doesn't work with external tables, needs different solution
        [archive].planning_assignment --FOR SYSTEM_TIME AS OF @reference_date
    UNION ALL
    SELECT -- Planning van activiteitgroepvoordrachten
	    unid = activiteitgroep_voordrachtid -- is gelijk aan de unid uit tabel dbo.activiteitgroep_voordracht
	    , startdatum
	    , aantal
	    , einddatum = LAG(startdatum) OVER (PARTITION BY activiteitgroep_voordrachtid ORDER BY startdatum DESC)
    FROM
        [archive].activiteitgroep_voordracht_planning --FOR SYSTEM_TIME AS OF @reference_date
    UNION ALL
    SELECT -- Planning van taakgroepvoordrachten
	    unid = task_assignmentid -- is gelijk aan de unid uit tabel dbo.taakvoordracht
	    , startdatum = startdate
	    , aantal = amount
	    , einddatum = LAG(startdate) OVER (PARTITION BY task_assignmentid ORDER BY startdate DESC)
    FROM
        [archive].planning_task_assignment --FOR SYSTEM_TIME AS OF @reference_date
    )

    INSERT INTO
	    Fact.PlanningHistory
	    (
	    NominationKey
	    , PlanningDate
	    , EstimatedWorkloadDaily
	    , EstimatedPlannedTurnover
	    )
    SELECT
	    NominationKey = n.NominationKey
	    , PlanningDate = d.[Date]
	    , EstimatedWorkloadDaily = CAST(COALESCE(p.aantal, n.WorkloadWeekly) / 5.0 AS decimal(9,2))
	    , EstimatedPlannedTurnover = n.HourlyRate * CAST(COALESCE(p.aantal, n.WorkloadWeekly) / 5.0 AS money)
    FROM
	    Dim.Nomination n
	    INNER JOIN d ON d.[Date] >= n.PlanningStartDate AND d.[Date] <= n.PlanningEndDate
	    LEFT OUTER JOIN PlanningWithEndDate p ON p.unid = n.unid AND p.startdatum <= d.[Date] AND (einddatum > d.[Date] OR einddatum IS NULL)
    WHERE 1=1
	    AND n.PlanningEndDate > '2015-12-31'
	    AND n.NominationType <> 'Public Task'
        AND d.[Date] = @planning_date;

    -- Haal de volgende datum op uit de cursor
    FETCH NEXT FROM ReferenceDate INTO @reference_date;
    SET @planning_date = @reference_date;
END;

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
