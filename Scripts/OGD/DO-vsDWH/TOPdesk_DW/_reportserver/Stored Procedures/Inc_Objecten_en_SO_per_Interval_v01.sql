
CREATE PROCEDURE [dbo].[Inc_Objecten_en_SO_per_Interval_v01]
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

/* Query om het gebruik van standaardoplossingen en objecten te laten zien */

/* Variabelen */
DECLARE @ReportStartDate AS datetime =	dbo.ReportStartDate(@ReportDate,@ReportPeriod,@ReportInterval)
DECLARE @ReportEndDate AS datetime = DATEADD(MI,-1,DATEADD(day,1,CAST(@ReportDate AS smalldatetime)))
-- Dit zorgt er voor dat de periode incl de gekozen rapport datum wordt ipv tot het begin van die dag. De periode loopt dus t/m 23:59 van de gekozen dag

/* Gefilterde meldingen */
SELECT
	Incident_Id
	, OperatorGroup
	, OperatorGroupSTD
	, IncidentDate
	, CreationDate
	, CompletionDate
	, ClosureDate
	, StandardSolution
	, ObjectID
	, IncidentType
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
WHERE 1=1
	AND (ClosureDate >= @ReportStartDate OR ClosureDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Aantal afgemelde meldingen */
;WITH IncClosed AS
(
SELECT 
	ClosureDate
	, AantalGesloten = COUNT(Incident_Id)
	, AantalSO = COUNT(StandardSolution)
	, AantalObj = COUNT(ObjectID)
FROM
	#FilteredIncidents
WHERE 1=1
	AND ClosureDate IS NOT NULL
GROUP BY
	ClosureDate
)

--SELECT * FROM IncClosed --ORDER BY Date

/* Aantal afgemelde meldingen */
, IncClosedVerstoringen AS
(
SELECT 
	ClosureDate
	, AantalGeslotenVerstoring = COUNT(Incident_Id)
	, AantalSOVerstoring = COUNT(StandardSolution)
	, AantalObjVerstoring = COUNT(ObjectID)
FROM
	#FilteredIncidents
WHERE 1=1
	AND ClosureDate IS NOT NULL
	AND IncidentType = 'Verstoring'
GROUP BY
	ClosureDate
)

--SELECT * FROM IncClosedVerstoring --ORDER BY Date

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
	, Objecten = ISNULL(AantalObj,0)
	, SO = ISNULL(AantalSO,0)

	, AfgemeldVerstoring = ISNULL(AantalGeslotenVerstoring,0)
	, ObjectenVerstoring = ISNULL(AantalObjVerstoring,0)
	, SOVerstoring = ISNULL(AantalSOVerstoring,0)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN IncClosed Cl ON D.[Date] = Cl.ClosureDate
	LEFT OUTER JOIN IncClosedVerstoringen V ON D.[Date] = V.ClosureDate	
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
	, Afgemeld = SUM(Afgemeld)
	, AfgemeldMetSO = SUM(SO)
	, AfgemeldZonderSO = (SUM(Afgemeld) - SUM(SO))
	, AfgemeldMetObj = SUM(Objecten)
	, AfgemeldZonderObj = (SUM(Afgemeld) - SUM(Objecten))

	, Verstoringen_Afgemeld = SUM(AfgemeldVerstoring)
	, Verstoringen_AfgemeldMetSO = SUM(SOVerstoring)
	, Verstoringen_AfgemeldZonderSO = (SUM(AfgemeldVerstoring) - SUM(SOVerstoring))
	, Verstoringen_AfgemeldMetObj = SUM(ObjectenVerstoring)
	, Verstoringen_AfgemeldZonderObj = (SUM(AfgemeldVerstoring) - SUM(ObjectenVerstoring))
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
EXEC [dbo].[Inc_Objecten_en_SO_per_Interval_v01]
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
*/