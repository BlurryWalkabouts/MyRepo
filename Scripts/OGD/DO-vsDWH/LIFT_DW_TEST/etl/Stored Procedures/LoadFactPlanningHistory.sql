CREATE PROCEDURE [etl].[LoadFactPlanningHistory]
AS
BEGIN

-- Test data: Workload, turnover, date randomized.
-- Select only planning for the nominations in our test set.

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE Fact.PlanningHistory

INSERT INTO
	Fact.PlanningHistory
	(
	NominationKey
	, PlanningDate
	, EstimatedWorkloadDaily
	, EstimatedPlannedTurnover
	)
SELECT
	h.NominationKey
	, PlanningDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, EstimatedWorkloadDaily = CASE
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.98 THEN 4.8
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.96 THEN 0.2
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.96 THEN 1.6
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.95 THEN 3.2
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.95 THEN 6.4
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.78 THEN 8.0
			ELSE 0.0
		END
	, EstimatedPlannedTurnover = ABS(CHECKSUM(NEWID()) % 90) * 4 + 40
FROM
	[$(LIFTDW)].Fact.PlanningHistory h
	INNER JOIN Dim.Nomination n ON h.NominationKey = n.NominationKey
WHERE 1=1
	AND h.PlanningDate >= '2016-01-01'

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END