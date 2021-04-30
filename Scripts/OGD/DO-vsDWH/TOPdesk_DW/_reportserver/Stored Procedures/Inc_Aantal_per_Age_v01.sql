
CREATE PROCEDURE [dbo].[Inc_Aantal_per_Age_v01] 
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
AS

BEGIN

/* 
	 */

/* Variabelen */
DECLARE @ReportStartDate AS datetime =	dbo.ReportStartDate(@ReportDate,@ReportPeriod,@ReportInterval)
DECLARE @ReportEndDate AS datetime = DATEADD(MI,-1,DATEADD(day,1,CAST(@ReportDate AS smalldatetime)))
-- Dit zorgt er voor dat de periode incl de gekozen rapport datum wordt ipv tot het begin van die dag. De periode loopt dus t/m 23:59 van de gekozen dag

/* Gefilterde meldingen */
SELECT
	Incident_Id
	, IncidentDate
	, CreationDate
	, CompletionDate
	, ClosureDate
	,  [5min]   = IIF(IncidentDate > DATEADD(Day,-6,@ReportDate),1,0)
	,  [5tot10] = IIF(IncidentDate BETWEEN DATEADD(Day,-10,@ReportDate) AND DATEADD(Day,-6,@ReportDate),1,0)
	, [10tot15] = IIF(IncidentDate BETWEEN DATEADD(Day,-15,@ReportDate) AND DATEADD(Day,-11,@ReportDate),1,0)
	, [15tot20] = IIF(IncidentDate BETWEEN DATEADD(Day,-20,@ReportDate) AND DATEADD(Day,-16,@ReportDate),1,0)
	, [20tot30] = IIF(IncidentDate BETWEEN DATEADD(Day,-30,@ReportDate) AND DATEADD(Day,-21,@ReportDate),1,0)
	, [30plus]  = IIF(IncidentDate < DATEADD(Day,-30,@ReportDate),1,0)
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
WHERE 1=1
	AND (ClosureDate >= @ReportStartDate OR ClosureDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Aantal openstaande meldingen */
;WITH IncOpen AS
(
SELECT
	D.[Date]
	, AantalOpen = COUNT(I.Incident_Id)
	,  T5min   = SUM([5min])
	,  T5tot10 = SUM([5tot10])
	, T10tot15 = SUM([10tot15])
	, T15tot20 = SUM([15tot20])
	, T20tot30 = SUM([20tot30])
	, T30plus  = SUM([30plus])
FROM
	Dim.[Date] D
	JOIN #FilteredIncidents I ON I.IncidentDate <= D.[Date] AND (I.CompletionDate > D.[Date] OR I.CompletionDate IS NULL)
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
GROUP BY
	D.[Date]
)

--SELECT * FROM IncOpen ORDER BY Date

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

	,  T5min   = SUM(T5min) OVER()
	,  T5tot10 = SUM(T5tot10) OVER()
	, T10tot15 = SUM(T10tot15) OVER()
	, T15tot20 = SUM(T15tot20) OVER()
	, T20tot30 = SUM(T20tot30) OVER()
	, T30plus  = SUM(T30plus) OVER()
FROM
	Dim.[Date] D
	LEFT OUTER JOIN IncOpen O ON D.[Date] = O.[Date]
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
)

--SELECT * FROM CountsPerDay ORDER BY Date

SELECT
	 max5       = MAX(T5min)
	,  [5tot10] = MAX(T5tot10)
	, [10tot15] = MAX(T10tot15)
	, [15tot20] = MAX(T15tot20)
	, [20tot30] = MAX(T20tot30)
	, [30plus]  = MAX(T30plus)
FROM
	CountsPerDay
GROUP BY
	T5min

END

/*
EXEC [dbo].[Inc_Aantal_per_Age_v01]
@Customer = '33'
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

, @ReportDate = '20160522'
, @ReportInterval = 'month'
, @ReportPeriod = 13
*/