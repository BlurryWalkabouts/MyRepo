CREATE PROCEDURE [etl].[LoadFactPlanning]
AS
BEGIN

-- Test data: Workload, turnover, date randomized.
-- Select only planning for the nominations in our test set.

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Fact.Planning

INSERT INTO
	Fact.Planning
	(
	NominationKey
	, PlanningDate
	, EstimatedWorkloadDaily
	, EstimatedPlannedTurnover
	)
SELECT
	p.NominationKey
	, PlanningDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, EstimatedWorkloadDaily = CASE
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.98 THEN 4.8
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.96 THEN 0.2
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.96 THEN 1.6
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.95 THEN 3.2
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.95 THEN 6.4
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.78 THEN 8.0
			ELSE 0.0
		END
	, EstimatedPlannedTurnover = ABS(CHECKSUM(NEWID()) % 90) * 4 + 40
FROM
	[$(LIFTDW)].Fact.Planning p
	INNER JOIN Dim.Nomination n ON p.NominationKey = n.NominationKey
WHERE 1=1
	AND p.PlanningDate >= '2016-01-01'

UNION ALL

-- Testklant: Planning is overal 8 uur p/d, 40 p/w
SELECT
	NominationKey = -2
	, PlanningDate = [Date]
	, EstimatedWorkloadDaily = 8
	, EstimatedPlannedTurnover = ABS(CHECKSUM(NEWID()) % 90) * 4 + 40
FROM
	Dim.[Date]
WHERE 1=1
	AND YEAR([Date]) = YEAR(CURRENT_TIMESTAMP)
	AND [DayOfWeek] < 6

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END