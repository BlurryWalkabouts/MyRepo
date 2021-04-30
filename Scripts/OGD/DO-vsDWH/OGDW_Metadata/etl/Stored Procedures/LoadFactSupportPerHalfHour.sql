CREATE PROCEDURE [etl].[LoadFactSupportPerHalfHour]
AS
BEGIN

-- =============================================
-- Author:		Mark Versteegh
-- Create date: 2015-08-19
-- Description:	maakt tabel fact.SupportPerHalfHour aan op basis van data uit MDS
-- in deze fact-tabel staat voOR ieder supportwindow voor iedere weekdag per half uur of er support is
-- 20161109 verplaatst naar ogdw_metadata, werkt nog niet goed, zie comment op regel 53
-- =============================================

SET NOCOUNT ON

IF (SELECT COUNT(DISTINCT SupportWindowKey) FROM [$(OGDW)].Fact.SupportPerHalfHour) < (SELECT COUNT(DISTINCT Code) FROM [$(MDS)].mdm.DimSupportWindow)
BEGIN

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

DELETE FROM [$(OGDW)].Fact.SupportPerHalfHour

-- Geef me alle weekdagen + tijden voor iedere SupportWindow-code
;WITH Tijdsblokken AS
(
SELECT DISTINCT
	[DayOfWeek] = CAST(d.[DayOfWeek] AS tinyint)
	, Half_hour_of_day = CAST(t.Half_hour_of_day AS tinyint)
	, SupportWindowKey = CAST(w.Code AS tinyint)
	, Time_half_hour_of_day = t.Time_half_hour_of_day
FROM
	[$(OGDW)].Dim.[Date] d
	, [$(OGDW)].Dim.[Time] t
	CROSS JOIN (SELECT Code FROM [$(MDS)].mdm.DimSupportWindow) w
WHERE 1=1
	AND d.[DayOfWeek] > 0
	AND t.[Time] IS NOT NULL
	AND DATEPART(MI,t.[Time]) % 30 = 0
	AND DATEPART(ss,t.[Time]) = 0
--	AND Code = 1 -- test
)

INSERT INTO
	[$(OGDW)].Fact.SupportPerHalfHour
	(
	SupportWindowKey
	, [DayOfWeek]
	, half_hour_of_day
	, Support
	)
SELECT
	SupportWindowKey = t.SupportWindowKey
	, [DayOfWeek] = t.[DayOfWeek]
	, Half_hour_of_day = t.Half_hour_of_day
	, Support = CAST(CASE WHEN w.Code IS NOT NULL THEN 1 ELSE 0 END AS bit)
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

-- 20161109 deze kolommen bestaan niet meer, nog controleren of resultaat nu klopt
-- MV, 20161219: als de data correct is ingevuld (dus wat eerst in start2/eind2 stond moet nu op een nieuwe regel staat), dan zou dit goed moeten gaan.
--		OR ([DayOfWeek] = 1 AND t.Time_half_hour_of_day >= w.MaStart2 AND t.Time_half_hour_of_day < w.MaEind2)
--		OR ([DayOfWeek] = 2 AND t.Time_half_hour_of_day >= w.DiStart2 AND t.Time_half_hour_of_day < w.DiEind2)
--		OR ([DayOfWeek] = 3 AND t.Time_half_hour_of_day >= w.WoStart2 AND t.Time_half_hour_of_day < w.WoEind2)
--		OR ([DayOfWeek] = 4 AND t.Time_half_hour_of_day >= w.DoStart2 AND t.Time_half_hour_of_day < w.DoEind2)
--		OR ([DayOfWeek] = 5 AND t.Time_half_hour_of_day >= w.VrStart2 AND t.Time_half_hour_of_day < w.VrEind2)
--		OR ([DayOfWeek] = 6 AND t.Time_half_hour_of_day >= w.ZaStart2 AND t.Time_half_hour_of_day < w.ZaEind2)
--		OR ([DayOfWeek] = 7 AND t.Time_half_hour_of_day >= w.ZoStart2 AND t.Time_half_hour_of_day < w.ZoEind2)
		)

SET @newRowCount += @@ROWCOUNT
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

END