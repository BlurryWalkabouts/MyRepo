
CREATE PROCEDURE [dbo].[Inc_Oplossnelheid_per_Interval_v02]
@Customer AS nvarchar(max)
, @SourceDatabase AS nvarchar(max)
, @IncSlaAchievedFlag AS nvarchar(max)
, @IncIsMajor AS nvarchar(max)
, @IncHandledByOgdFlag AS nvarchar(max)
, @IncCategory AS nvarchar(max)
, @IncEntryType AS nvarchar(max)
, @IncEntryTypeSTD AS nvarchar(max)
, @IncImpact AS nvarchar(max)
, @IncLine AS nvarchar(max)
, @ObjID AS nvarchar(max)
, @IncPriority AS nvarchar(max)
, @IncPrioritySTD AS nvarchar(max)
, @IncSLA AS nvarchar(max)
, @CustomerSLA AS nvarchar(max)
, @IncStandardSolution AS nvarchar(max)
, @IncStatus AS nvarchar(max)
, @IncStatusSTD AS nvarchar(max)
, @IncSubcategory AS nvarchar(max)
, @IncSupplier AS nvarchar(max)
, @IncType AS nvarchar(max)
, @IncTypeSTD AS nvarchar(max)
, @CustomerGroup AS nvarchar(max)
, @EndUserService AS nvarchar(max)
, @SysAdminService AS nvarchar(max)
, @OperatorGroup AS nvarchar(max)
, @OperatorGroupSTD AS nvarchar(max)
, @EntryOperatorGroup AS nvarchar(max)
, @EntryOperatorGroupSTD AS nvarchar(max)
, @CallerBranch AS nvarchar(max)
, @CallerCity AS nvarchar(max)
, @CallerDepartment AS nvarchar(max)

, @ReportDate AS date
, @ReportInterval AS nvarchar(50)
, @ReportPeriod AS int

-- Bins moeten naar MDS
, @ReportDurationBin1 AS int = 60 -- Bepaalt, in minuten, de eerste oplossnelheidcategorie voor de afgesloten meldingen
, @ReportDurationBin2 AS int = 120 -- Bepaalt, in minuten, de tweede oplossnelheidcategorie voor de afgesloten meldingen
, @ReportDurationBin3 AS int = 480 -- Bepaalt, in minuten, de derde oplossnelheidcategorie voor de afgesloten meldingen
AS

BEGIN

/* Query om het aantal aangemelde, afgemelde, openstaande en gereedgemelde meldingen
	te bepalen voor een opgegeven periode, bron en selectie van Behandelaarsgroepen

	Geschreven door Wouter Gielen */

/* Variabelen */
DECLARE @ReportStartDate AS datetime =	dbo.ReportStartDate(@ReportDate,@ReportPeriod,@ReportInterval)
DECLARE @ReportEndDate AS datetime = DATEADD(MI,-1,DATEADD(day,1,CAST(@ReportDate AS smalldatetime)))
-- Dit zorgt er voor dat de periode incl de gekozen rapport datum wordt ipv tot het begin van die dag. De periode loopt dus t/m 23:59 van de gekozen dag

/* Gefilterde meldingen */
SELECT
	Incident_Id
	, IncidentDate
	, ClosureDate
	, DurationAdjustedActualCombi
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
WHERE 1=1
	AND (ClosureDate >= @ReportStartDate OR ClosureDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Aantal afgemelde meldingen per dag en per bin */
;WITH IncClosed AS
(
SELECT 
	D.[Date]
	, AantalGesloten = COUNT(Incident_Id)
	, AantalGeslotenBin1 = SUM(IIF(I.DurationAdjustedActualCombi<@ReportDurationBin1,1,0))
	, AantalGeslotenBin2 = SUM(IIF(I.DurationAdjustedActualCombi<@ReportDurationBin2,1,0))
	, AantalGeslotenBin3 = SUM(IIF(I.DurationAdjustedActualCombi<@ReportDurationBin3,1,0))
FROM
	Dim.[Date] D
	LEFT OUTER JOIN #FilteredIncidents I ON I.ClosureDate = D.[Date]
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
GROUP BY
	D.[Date]
)

--SELECT * FROM IncClosed --ORDER BY Date

/* Alles samenvoegen tot een tabel, van het aantal openstaande meldingen wordt het aantal gereedgemelde meldingen afgetrokken */
, CountsPerDay AS
(
SELECT
	D.CalendarYear
	, WeekYear
	, D.DWMonthNumber
	, D.DWWeekNumber
	, D.DateKey
	, D.MonthOfYear AS [Month]
	, D.Weeknumber AS [Week]
	, D.[Date]
	, D.NL_MonthShort

	, Afgemeld = ISNULL(AantalGesloten,0)
	, AfgemeldBin1 = ISNULL(AantalGeslotenBin1,0)
	, AfgemeldBin2 = ISNULL(AantalGeslotenBin2,0)
	, AfgemeldBin3 = ISNULL(AantalGeslotenBin3,0)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN IncClosed Cl ON D.[Date] = Cl.[Date]
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
)

--SELECT * FROM CountsPerDay ORDER BY Date, Subcategory

, EndResult AS
(
SELECT
	DWInterval = CASE @ReportInterval
			WHEN 'Month' THEN DWMonthnumber
			WHEN 'Week' THEN DWWeeknumber
			WHEN 'Day' THEN Datekey
		END
	, Jaar = CASE @ReportInterval
			WHEN 'Week' THEN WeekYear
			ELSE CalendarYear
		END
	, Interval = CASE @ReportInterval
			WHEN 'Month' THEN CAST([Month] AS nvarchar(12))
			WHEN 'Week' THEN CAST([Week] AS nvarchar(12))
			WHEN 'Day' THEN CONVERT(nvarchar(12),[Date],5)
		END
	, IntervalString = CASE @ReportInterval
			WHEN 'Month' THEN NL_MonthShort
			WHEN 'Week' THEN 'Week ' + CAST([Week] AS nvarchar(12))
			WHEN 'Day' THEN CONVERT(nvarchar(12),[Date],5)
		END
	, Closed = SUM(Afgemeld)
	, ClosedBin1 = SUM(AfgemeldBin1)
	, ClosedBin2 = SUM(AfgemeldBin2)
	, ClosedBin3 = SUM(AfgemeldBin3)
	, ClosedBin1Perc = IIF(SUM(Afgemeld)=0,1,CAST(SUM(AfgemeldBin1) AS decimal(9,2)) / CAST(SUM(Afgemeld) AS decimal(9,2)))
	, ClosedBin2Perc = IIF(SUM(Afgemeld)=0,1,CAST(SUM(AfgemeldBin2) AS decimal(9,2)) / CAST(SUM(Afgemeld) AS decimal(9,2)))
	, ClosedBin3Perc = IIF(SUM(Afgemeld)=0,1,CAST(SUM(AfgemeldBin3) AS decimal(9,2)) / CAST(SUM(Afgemeld) AS decimal(9,2)))
FROM
	CountsPerDay
GROUP BY
	CASE @ReportInterval
			WHEN 'Week' THEN WeekYear
			ELSE CalendarYear
		END
	, CASE @ReportInterval
			WHEN 'Month' THEN DWMonthnumber
			WHEN 'Week' THEN DWWeeknumber
			WHEN 'Day' THEN Datekey
		END
	, CASE @ReportInterval
			WHEN 'Month' THEN CAST([Month] AS nvarchar(12))
			WHEN 'Week' THEN CAST([Week] AS nvarchar(12))
			WHEN 'Day' THEN CONVERT(nvarchar(12),[Date],5)
		END
	, CASE @ReportInterval
			WHEN 'Month' THEN NL_MonthShort
			WHEN 'Week' THEN 'Week ' + CAST([Week] AS nvarchar(12))
			WHEN 'Day' THEN CONVERT(nvarchar(12),[Date],5)
		END
)

SELECT
	*
FROM
	EndResult
ORDER BY
	DWInterval

END

/*
EXEC [dbo].[Inc_Oplossnelheid_per_Interval_v02]
@Customer = '44'
, @SourceDatabase = '-99'
, @IncSlaAchievedFlag = 1
, @IncIsMajor = 1
, @IncHandledByOgdFlag = 1
, @IncCategory = 'All'
, @IncEntryType = 'All'
, @IncEntryTypeSTD = 'All'
, @IncImpact = 'All'
, @IncLine = 'All'
, @ObjID = 'All'
, @IncPriority = 'All'
, @IncPrioritySTD = 'All'
, @IncSLA = 'All'
, @CustomerSLA = 'All'
, @IncStandardSolution = 'All'
, @IncStatus = 'All'
, @IncStatusSTD = 'All'
, @IncSubcategory = 'All'
, @IncSupplier = 'All'
, @IncType = 'All'
, @IncTypeSTD = 'All'
, @CustomerGroup = 'All'
, @EndUserService = 'All'
, @SysAdminService = 'All'
, @OperatorGroup = 'All'
, @OperatorGroupSTD = 'All'
, @EntryOperatorGroup = 'All'
, @EntryOperatorGroupSTD = 'All'
, @CallerBranch = 'All'
, @CallerCity = 'All'
, @CallerDepartment = 'All'

, @ReportDate = '20160331'
, @ReportInterval = 'month'
, @ReportPeriod = 13

-- Bins moeten naar MDS
, @ReportDurationBin1 = 60 -- Bepaalt, in minuten, de eerste oplossnelheidcategorie voor de afgesloten meldingen
, @ReportDurationBin2 = 120 -- Bepaalt, in minuten, de tweede oplossnelheidcategorie voor de afgesloten meldingen
, @ReportDurationBin3 = 480 -- Bepaalt, in minuten, de derde oplossnelheidcategorie voor de afgesloten meldingen
*/