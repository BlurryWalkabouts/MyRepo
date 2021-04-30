CREATE PROCEDURE [etl].[LoadDimHourType]
AS
BEGIN

-- Test data: Percentage randomized (usually 100%), Billable randomized (50% true).

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Dim.HourType

INSERT INTO
	Dim.HourType
	(
	HourTypeKey
	, [Percentage]
	, Billable
	, RateName
	)
SELECT
	HourTypeKey
	, [Percentage] = CASE
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.96 THEN 150.0
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.96 THEN 125.0
			WHEN RAND(CAST(NEWID() AS varbinary)) > 0.96 THEN  15.0
			ELSE 100.0
		END
	, Billable = CASE RAND(CAST(NEWID() AS varbinary)) WHEN 0.5 THEN 1 ELSE 0 END
	, RateName
FROM
	[$(LIFTDW)].Dim.HourType

EXEC etl.[Log] @@PROCID
COMMIT TRANSACTION

END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC etl.[Log] @@PROCID
END CATCH

END