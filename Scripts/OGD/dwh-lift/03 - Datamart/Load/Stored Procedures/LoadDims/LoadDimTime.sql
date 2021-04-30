CREATE PROCEDURE [Load].[LoadDimTime]
(
	@WriteLog bit = 1
)
AS
BEGIN

-- ================================================
-- Create dim table for Time.
-- This is a straight copy from MDS.
-- 
-- DimTime is in MDS gedefinieerd per minuut, omdat het bewerken van duizenden regels niet zo soepel 
-- gaat in MDS. Deze sproc voegt hier de secondes aan toe zodat we weer volledige tijden hebben. 
-- De regel met TimeKey = -1 is voor niet bestaande/ongeldige tijden. 
-- =============================================

SET NOCOUNT ON

DECLARE @recordCount int = (SELECT COUNT(TimeKey) FROM Dim.[Time])

IF @recordCount = 0
BEGIN

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

CREATE TABLE #temp_time
(
	TimeKey int NULL
	, minute_of_day int NULL
	, hour_of_day_24 decimal(38) NULL
	, hour_of_day_12 decimal(38) NULL
	, am_pm nvarchar(100) NULL
	, minute_of_hour decimal(38) NULL
	, half_hour decimal(38) NULL
	, half_hour_of_day decimal(38) NULL
	, quarter_hour decimal(38) NULL
	, quarter_hour_of_day decimal(38) NULL
	, Time_half_hour_of_day time(0) NULL
)

INSERT INTO
	#temp_time
SELECT
	TimeKey = CAST(Code AS int)
	, minute_of_day = CAST(minute_of_day AS int)
	, hour_of_day_24
	, hour_of_day_12
	, am_pm
	, minute_of_hour
	, half_hour
	, half_hour_of_day
	, quarter_hour
	, quarter_hour_of_day
	, Time_half_hour_of_day = CASE WHEN ISDATE(Time_half_hour_of_day) = 0 THEN NULL ELSE CAST(Time_half_hour_of_day AS time(0)) END
FROM
	[$(MDSServer)].[$(MDS)].mdm.DimTime

-- Add seconds:
;WITH Seconds AS
(
SELECT sec = 0
UNION ALL
SELECT sec = sec + 1
FROM Seconds
WHERE sec + 1 < 60
)

, DimTimeWithSeconds AS
(
-- Een regel voor niet bestaande tijden (TimeKey = -1)
SELECT
	TimeKey
	, minute_of_day
	, hour_of_day_24
	, hour_of_day_12
	, am_pm
	, minute_of_hour
	, half_hour
	, half_hour_of_day
	, quarter_hour
	, quarter_hour_of_day
	, Time_half_hour_of_day
	, [Time] = NULL
FROM
	#temp_time
WHERE 1=1
	AND TimeKey < 0
UNION
-- Voor alle overige regels een regel per seconde
SELECT
	TimeKey
	, minute_of_day
	, hour_of_day_24
	, hour_of_day_12
	, am_pm
	, minute_of_hour
	, half_hour
	, half_hour_of_day
	, quarter_hour
	, quarter_hour_of_day
	, Time_half_hour_of_day
	, [Time] = CAST(CAST(hour_of_day_24 AS char(2)) + ':' + CAST(minute_of_hour AS char(2)) + ':' + CAST(sec AS char(2)) AS time(0))
FROM
	#temp_time
	CROSS JOIN Seconds --OPTION (MAXRECURSION 0)
WHERE 1=1
	AND TimeKey >=0
)

INSERT INTO
	Dim.[Time]
	(
	TimeKey
	, minute_of_day
	, hour_of_day_24
	, hour_of_day_12
	, am_pm
	, minute_of_hour
	, half_hour
	, half_hour_of_day
	, quarter_hour
	, quarter_hour_of_day
	, Time_half_hour_of_day
	, [Time]
	)
SELECT
	TimeKey = CASE WHEN TimeKey >=0 THEN DATEDIFF(SS, 0, [Time]) ELSE TimeKey END --datepart(hh,Time) * 3600 + datepart(mi,Time) * 60 + datepart(ss,Time)
	, minute_of_day
	, hour_of_day_24
	, hour_of_day_12
	, am_pm
	, minute_of_hour
	, half_hour
	, half_hour_of_day
	, quarter_hour
	, quarter_hour_of_day
	, Time_half_hour_of_day
	, [Time]
FROM
	DimTimeWithSeconds
--ORDER BY
--	TimeKey

SET @newRowCount += @@ROWCOUNT

DROP TABLE IF EXISTS #temp_time

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

END