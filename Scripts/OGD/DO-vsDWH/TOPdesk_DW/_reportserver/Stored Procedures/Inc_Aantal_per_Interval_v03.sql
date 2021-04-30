
CREATE PROCEDURE [dbo].[Inc_Aantal_per_Interval_v03] 
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
	, OperatorGroup
	, OperatorGroupSTD
	, IncidentDate
	, CreationDate
	, CompletionDate
	, ClosureDate
	, Subcategory
	, Category
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
WHERE 1=1
	AND (ClosureDate >= @ReportStartDate OR ClosureDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Aantal aangemelde meldingen */
;WITH IncCreated AS
(
SELECT 
	IncidentDate
	, AantalAangemeld = COUNT(Incident_Id)
FROM
	#FilteredIncidents
GROUP BY
	IncidentDate
)
 
--SELECT * FROM IncCreated ORDER BY IncidentDate

/* Aantal afgemelde meldingen */
, IncClosed AS
(
SELECT 
	ClosureDate
	, AantalGesloten = COUNT(Incident_Id)
FROM 
	#FilteredIncidents
WHERE 1=1
	AND ClosureDate IS NOT NULL
GROUP BY
	ClosureDate
)

--SELECT * FROM IncClosed --ORDER BY Date

/* Aantal openstaande meldingen */
, IncOpen AS
(
SELECT
	D.[Date]
	, AantalOpen = COUNT(I.Incident_Id)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN #FilteredIncidents I ON I.IncidentDate <= D.[Date] AND (I.CompletionDate > D.[Date] OR I.CompletionDate IS NULL)
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
GROUP BY
	D.[Date]
)

--SELECT * FROM IncOpen --ORDER BY Date

/* Aantal gereedgemelde, niet afgemelde meldingen */
, IncGereed AS
(
SELECT
	D.[Date]
	, AantalGereed = COUNT(I.Incident_Id)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN #FilteredIncidents I ON I.CompletionDate <= D.[Date] AND (I.ClosureDate > D.[Date] OR I.ClosureDate IS NULL)
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
GROUP BY
	D.[Date]
)

--SELECT * FROM IncGereed --ORDER BY Date

/* De uren die ingezet zijn per klantgroep op de SSD om het aantal meldingen per uur uit te kunnen rekenen */
, [Hours] AS
(
SELECT
	[Date]
	, [Hours] = SUM([Hours])
FROM
	Fact.vwWorkforceResourcesPerDay
WHERE 1=1
	AND ('All' IN(@CustomerGroup) OR CustomerGroup IN (SELECT * FROM [fn_CSVToTable](@CustomerGroup)))
GROUP BY
	[Date]
)

--SELECT * FROM [Hours]

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

	, Aangemeld = ISNULL(AantalAangemeld,0)
	, AangemeldNull = AantalAangemeld
	, TotaalAangemeld = SUM(AantalAangemeld) OVER ()
	, Afgemeld = ISNULL(AantalGesloten,0)
	, [Open] = ISNULL(AantalOpen,0)
	, Gereed = ISNULL(AantalGereed,0)

	, OpenEndofInterval = FIRST_VALUE(AantalOpen) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, GereedEndofInterval = FIRST_VALUE(AantalGereed) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, OpenMinofInterval = MIN(AantalOpen) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
	, GereedMinofInterval = MIN(AantalGereed) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
	, OpenMaxofInterval = MAX(AantalOpen) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
	, GereedMaxofInterval = MAX(AantalGereed) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
	, OpenAVGofInterval = AVG(AantalOpen) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
	, GereedAVGofInterval = AVG(AantalGereed) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
	, MeldingenPerPersoonPerUur = CAST(ISNULL(AantalAangemeld,0) / NULLIF(H.[Hours],0) AS decimal (6,3))
	, ActiefInterval = MAX(IIF(AantalAangemeld IS NULL,NULL,1)) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN IncCreated Cr ON D.[Date] = Cr.IncidentDate
	LEFT OUTER JOIN IncClosed Cl ON D.[Date] = Cl.ClosureDate
	LEFT OUTER JOIN IncOpen O ON D.[Date] = O.[Date]
	LEFT OUTER JOIN IncGereed G ON D.[Date] = G.[Date]
	LEFT OUTER JOIN [Hours] H ON D.[Date] = H.[Date]
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
)

--SELECT * FROM CountsPerDay ORDER BY Date, Subcategory

, EndResult AS
(
SELECT
	DWInterval = CASE @ReportInterval
			WHEN 'Month' THEN DWMonthNumber
			WHEN 'Week' THEN DWWeekNumber
			WHEN 'Day' THEN DateKey
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
	, Aangemeld = SUM(Aangemeld)
	, AangemeldNull = SUM(AangemeldNull)
	, Afgemeld = SUM(Afgemeld)
	, AvgAangemeld = MAX(ISNULL(TotaalAangemeld,0)) / COUNT(ActiefInterval) OVER ()
	, AvgAangemeld2 = MAX(ISNULL(TotaalAangemeld,0)) / @ReportPeriod --neemt intervallen zonder data ook mee
	, [Open] = MAX(ISNULL(OpenEndofInterval,0))
	, MinOpen = MAX(ISNULL(OpenMinofInterval,0))
	, MaxOpen = MAX(ISNULL(OpenMaxofInterval,0))
	, AvgOpen = MAX(ISNULL(OpenAVGofInterval,0))
	, Gereed = MAX(ISNULL(GereedEndofInterval,0))
	, MinGereed = MAX(ISNULL(GereedMinofInterval,0))
	, MaxGereed = MAX(ISNULL(GereedMaxofInterval,0))
	, AvgGereed = MAX(ISNULL(GereedAVGofInterval,0))
	, AvgMeldingenPerPersoonPerUur = AVG(MeldingenPerPersoonPerUur)
	, MaxMeldingenPerPersoonPerUur = MAX(ISNULL(MeldingenPerPersoonPerUur,0))
FROM
	CountsPerDay
GROUP BY
	CASE @ReportInterval
			WHEN 'Week' THEN WeekYear
			ELSE CalendarYear
		END
	, CASE @ReportInterval
			WHEN 'Month' THEN DWMonthNumber
			WHEN 'Week' THEN DWWeekNumber
			WHEN 'Day' THEN DateKey
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
	, ActiefInterval
)

SELECT
	*
FROM
	EndResult
ORDER BY
	DWInterval

END

/*
EXEC [dbo].[Inc_Aantal_per_Interval_v03]
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

, @ReportDate = '20150731'
, @ReportInterval = 'month'
, @ReportPeriod = 13
*/