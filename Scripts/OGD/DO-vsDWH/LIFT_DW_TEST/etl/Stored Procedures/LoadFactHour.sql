CREATE PROCEDURE [etl].[LoadFactHour]
AS
BEGIN

-- Test data: Dates, rate, hours, FKs randomized. Productnomination is always NULL in source data.
-- Select only hours for employees in our test set.

BEGIN TRY

BEGIN TRANSACTION

TRUNCATE TABLE Fact.[Hour]

INSERT INTO
	Fact.[Hour]
	(
	unid
	, ProjectKey
	, CustomerKey
	, EmployeeKey
	, HourTypeKey
	, ServiceKey
	, [Hours]
	, [Day]
	, ChangeDate
	, Rate
	, ProductNomination
	)
SELECT
	h.[unid]
	, h.ProjectKey
	, h.CustomerKey
	, h.EmployeeKey
	, HourTypeKey = ABS(CHECKSUM(NEWID()) % 1300) + 50000000
	, ServiceKey = ABS(CHECKSUM(NEWID()) % 150) + 60000000
	, [Hours] = CASE
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 3.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 5.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 6.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 7.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 9.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.92 THEN 2.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.89 THEN 1.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.86 THEN 4.0
			ELSE 8.0
		END
	, [Day] = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, ChangeDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, Rate = ABS(CHECKSUM(NEWID()) % 90) + 20
	, ProductNomination = NULL
FROM
	[$(LIFTDW)].Fact.[Hour] h
	INNER JOIN Dim.Employee e ON h.EmployeeKey = e.EmployeeKey
WHERE 1=1
	AND ChangeDate >= '2016-01-01'

UNION ALL

-- 1 medewerker, standaard overal 8 uur per dag
SELECT
	unid = NEWID()
	, ProjectKey = -2
	, CustomerKey = -2
	, EmployeeKey = -2
	, HourTypeKey = ABS(CHECKSUM(NEWID()) % 1300) + 50000000
	, ServiceKey = ABS(CHECKSUM(NEWID()) % 150) + 60000000
	, [Hours] = 8.0
	, [Day] = [Date]
	, ChangeDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, Rate = ABS(CHECKSUM(NEWID()) % 90) + 20
	, ProductNomination = NULL
FROM
	Dim.[Date]
WHERE 1=1
	AND YEAR([Date]) = YEAR(CURRENT_TIMESTAMP)
	AND [DayOfWeek] < 6

UNION ALL

-- 1 medewerker, wisselende uren = 40 p/w
SELECT
	unid = NEWID()
	, ProjectKey = -2
	, CustomerKey = -2
	, EmployeeKey = -3
	, HourTypeKey = ABS(CHECKSUM(NEWID()) % 1300) + 50000000
	, ServiceKey = ABS(CHECKSUM(NEWID()) % 150) + 60000000
	, [Hours] = CAST ([DayOfWeek] * 2.9 AS int)
	, [Day] = [Date]
	, ChangeDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, Rate = ABS(CHECKSUM(NEWID()) % 90) + 20
	, ProductNomination = NULL
FROM
	Dim.[Date]
WHERE 1=1
	AND YEAR([Date]) = YEAR(CURRENT_TIMESTAMP)
	AND [DayOfWeek] < 6

UNION ALL

-- 1 medewerker, wisselende uren (over/onder/gewoon)
SELECT
	unid = NEWID()
	, ProjectKey = -2
	, CustomerKey = -2
	, EmployeeKey = -4
	, HourTypeKey = ABS(CHECKSUM(NEWID()) % 1300) + 50000000
	, ServiceKey = ABS(CHECKSUM(NEWID()) % 150) + 60000000
	, [Hours] = CASE
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 3.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 5.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 6.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 7.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.97 THEN 9.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.92 THEN 2.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.89 THEN 1.0
			WHEN RAND(CAST(NEWID() AS VARBINARY)) > 0.86 THEN 4.0
			ELSE 8.0
		END
	, [Day] = [Date]
	, ChangeDate = DATEADD(DD, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')
	, Rate = ABS(CHECKSUM(NEWID()) % 90) + 20
	, ProductNomination = NULL
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