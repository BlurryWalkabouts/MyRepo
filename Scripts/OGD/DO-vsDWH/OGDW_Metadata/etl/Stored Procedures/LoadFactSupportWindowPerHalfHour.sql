CREATE PROCEDURE [etl].[LoadFactSupportWindowPerHalfHour]
(
	@YearToGenerate int
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
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

--TRUNCATE TABLE [$(OGDW)].Fact.SupportWindowPerHalfHour

--SET @YearToGenerate = 2017

;WITH Tijdsblokken AS
(
SELECT DISTINCT
	[Datetime] = CONVERT(datetime, CONVERT(char(8), dt.[Date], 112)  + ' ' + CONVERT(char(8), dt.[Time], 108))
	, [TimeStamp] = DATEDIFF(SS, '19700101', CONVERT(datetime, CONVERT(char(8), dt.[Date], 112) + ' ' + CONVERT(char(8), dt.[Time], 108)))
	, [DayOfWeek] = CAST(dt.[DayOfWeek] AS tinyint)
	, Half_hour_of_day = CAST(dt.Half_hour_of_day AS tinyint)
	, SupportWindowKey = CAST(w.Code AS tinyint)
	, SupportWindowID = w.SupportWindowID
	, Time_half_hour_of_day = dt.Time_half_hour_of_day
FROM
	[$(OGDW)].Dim.vwDateTimeHalfHours dt
	CROSS JOIN (SELECT Code, SupportWindowID FROM [$(MDS)].mdm.DimSupportWindow) w
WHERE 1=1
	AND dt.[DayOfWeek] > 0
)

/*
Because table [SupportWindowPerHalfHour] is filled from MDS, values can change. To support this
we will keep this history but always update the future according to the most recent verison 
of MDS. To do this we need to remove all records after today. This will be filled in the next step
*/

INSERT INTO
	[$(OGDW)].Fact.SupportWindowPerHalfHour
	(
	[Datetime]
	, [TimeStamp]
	, Half_hour_of_day
	, SupportWindowID
	, Support
	, SupportedRN
	, TotalRN
	)
SELECT
	[Datetime] = t.[Datetime]
	, [TimeStamp] = t.[TimeStamp]
	, Half_hour_of_day = t.Half_hour_of_day
	, SupportWindowID = t.SupportWindowID
	, Support = CAST(CASE WHEN MAX(w.Code) IS NOT NULL THEN 1 ELSE 0 END AS bit)
	, SupportedRN = NULL
	, TotalRN = NULL
FROM
	Tijdsblokken t 
	LEFT OUTER JOIN [$(MDS)].mdm.DimSupportWindow w ON t.SupportWindowKey = w.Code 
		AND
		(
		   (t.[DayOfWeek] = 1 AND t.Time_half_hour_of_day >= w.MaStart AND t.Time_half_hour_of_day < w.MaEind)
		OR (t.[DayOfWeek] = 2 AND t.Time_half_hour_of_day >= w.DiStart AND t.Time_half_hour_of_day < w.DiEind)
		OR (t.[DayOfWeek] = 3 AND t.Time_half_hour_of_day >= w.WoStart AND t.Time_half_hour_of_day < w.WoEind)
		OR (t.[DayOfWeek] = 4 AND t.Time_half_hour_of_day >= w.DoStart AND t.Time_half_hour_of_day < w.DoEind)
		OR (t.[DayOfWeek] = 5 AND t.Time_half_hour_of_day >= w.VrStart AND t.Time_half_hour_of_day < w.VrEind)
		OR (t.[DayOfWeek] = 6 AND t.Time_half_hour_of_day >= w.ZaStart AND t.Time_half_hour_of_day < w.ZaEind)
		OR (t.[DayOfWeek] = 7 AND t.Time_half_hour_of_day >= w.ZoStart AND t.Time_half_hour_of_day < w.ZoEind)
		)
WHERE 1=1
	AND YEAR(t.[Datetime]) = @YearToGenerate
GROUP BY
	t.[Datetime]
	, t.[TimeStamp]
	, t.Half_hour_of_day
	, t.SupportWindowID 

SET @newRowCount += @@ROWCOUNT

-- Fill temp table with SupportedRN and totalRN
CREATE TABLE #temp_DimSupportWindow
(
	[Datetime] datetime
	, SupportWindowID int
	, SupportedRN int
	, MaxSupportedRN int
	, TotalRN int
	, MaxTotalRN int
)

TRUNCATE TABLE #temp_DimSupportWindow

INSERT INTO
	#temp_DimSupportWindow
	(
	[Datetime]
	, SupportWindowID
	, SupportedRN
	, MaxSupportedRN
	, TotalRN
	, MaxTotalRN
	)
SELECT
	[Datetime] = spw.[Datetime]
	, SupportWindowID = spw.SupportWindowID
	, SupportedRN = SUM(Support) OVER (PARTITION BY spw.SupportWindowID ORDER BY spw.[Datetime] ROWS UNBOUNDED PRECEDING)
	, MaxSupportedRN = (SELECT MAX(SupportedRN) FROM [$(OGDW)].Fact.SupportWindowPerHalfHour spw1 WHERE spw1.SupportWindowID = spw.SupportWindowID)
	, TotalRN = ROW_NUMBER() OVER (PARTITION BY spw.SupportWindowID ORDER BY spw.[Datetime])
	, MaxTotalRN = (SELECT MAX(TotalRN) FROM [$(OGDW)].Fact.SupportWindowPerHalfHour spw1 WHERE spw1.SupportWindowID = spw.SupportWindowID)
FROM
	[$(OGDW)].Fact.SupportWindowPerHalfHour spw
WHERE 1=1
	AND YEAR(spw.[Datetime]) = @YearToGenerate

-- Update fact table with counters
UPDATE
	spw
SET
	spw.SupportedRN = temp.SupportedRN + ISNULL(temp.MaxSupportedRN,0)
	, spw.TotalRN = temp.TotalRN + ISNULL(temp.MaxTotalRN,0)
FROM
	[$(OGDW)].Fact.SupportWindowPerHalfHour spw
	INNER JOIN #temp_DimSupportWindow temp ON temp.[Datetime] = spw.[Datetime] AND temp.SupportWindowID = spw.SupportWindowID
WHERE 1=1
	AND YEAR(spw.[Datetime]) = @YearToGenerate

DROP TABLE #temp_DimSupportWindow

/*************************************************
exec ogdw_metadata.setup.[CreateFactSupportWindowPerHalfHour] 2017

delete from [$(OGDW)].[Fact].[SupportWindowPerHalfHour]
where dateti
select * 
from #temp_DimSupportWindow
where supportwindowID = 14me >  '2016-12-31 23:30:00.000'

select *
from [$(OGDW)].[Fact].[SupportWindowPerHalfHour] spw
where datetime  > '2016-12-30 23:30:00.000'
and spw.SupportWindowID = 14
order by datetime

select *
from [$(OGDW)].[Fact].[SupportWindowPerHalfHour] spw
where supportedRN =     61506
delete from [$(OGDW)].[Fact].[SupportWindowPerHalfHour]
where datetime >  '2016-12-31 23:30:00.000'
*****************************************************/

COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END