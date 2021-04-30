
CREATE PROCEDURE [dbo].[Inc_Age_per_Interval_v02] 
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
, @ReportIncAgeBin1 AS int = 3 -- Bepaalt de eerste leeftijdscategorie voor de openstaande meldingen
, @ReportIncAgeBin2 AS int = 5 -- Bepaalt de tweede leeftijdscategorie voor de openstaande meldingen
, @ReportIncAgeBin3 AS int = 10 -- Bepaalt de derde leeftijdscategorie voor de openstaande meldingen
AS

BEGIN

/*	Query om te bepalen hoeveel openstaande en gereedgemelde meldingen in bepaalde leeftijdsbins er waren
	voor een opgegeven periode

	Geschreven door Wouter Gielen */

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
	, SupportWeekend = 0
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
WHERE 1=1
	AND (ClosureDate >= @ReportStartDate OR ClosureDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Leeftijd van individuele openstaande meldingen per dag */
;WITH IncAgeOpen AS
(
SELECT
	D.[Date]
	, I.Incident_Id
	, NumDays = CASE WHEN (SupportWeekend = 1) THEN D.DWDayNumber - DI.DWDayNumber ELSE D.DWWorkDayNumber - DI.DWWorkDayNumber END + 1
FROM
	Dim.[Date] D
	LEFT OUTER JOIN #FilteredIncidents I ON I.IncidentDate <= D.[Date] AND (I.CompletionDate > D.[Date] OR I.CompletionDate IS NULL)
	LEFT OUTER JOIN Dim.[Date] DI ON I.IncidentDate = DI.[Date]
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
)

--SELECT * FROM IncAgeOpen ORDER BY [Date], Incident_Id

/* Aantal openstaande meldingen per dag */
, IncCountOpen AS
(
SELECT
	[Date]
	, AantalOpen = COUNT(Incident_Id)
	, Bin1 = SUM(IIF(NumDays<@ReportIncAgeBin1, 1, 0))
	, Bin2 = SUM(IIF(NumDays>=@ReportIncAgeBin1 AND NumDays <@ReportIncAgeBin2, 1, 0))
	, Bin3 = SUM(IIF(NumDays>=@ReportIncAgeBin2 AND NumDays <@ReportIncAgeBin3, 1, 0))
	, Bin4 = SUM(IIF(NumDays>=@ReportIncAgeBin3, 1, 0))
FROM
	IncAgeOpen
GROUP BY
	[Date]
)

--SELECT * FROM IncCountOpen ORDER BY [Date]

/* Leeftijd van individuele gereedgemelde meldingen per dag */
, IncAgeGereed AS
(
SELECT
	D.[Date]
	, I.Incident_Id
	, NumDays = CASE WHEN (SupportWeekend = 1) THEN D.DWDayNumber - DI.DWDayNumber ELSE D.DWWorkDayNumber - DI.DWWorkDayNumber END + 1
From
	Dim.[Date] D
	LEFT OUTER JOIN #FilteredIncidents I ON I.CompletionDate <= D.[Date] AND (I.ClosureDate > D.[Date] OR I.ClosureDate IS NULL)
	LEFT OUTER JOIN Dim.[Date] DI ON I.CompletionDate = DI.[Date]
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate  
)

--SELECT * FROM IncAgeGereed ORDER BY [Date], Incident_Id

/* Aantal gereedgemelde meldingen per dag */
, IncCountGereed AS
(
SELECT
	[Date]
	, AantalGereed = COUNT(Incident_Id)
	, Bin1 = SUM(IIF(NumDays<@ReportIncAgeBin1, 1, 0))
	, Bin2 = SUM(IIF(NumDays>=@ReportIncAgeBin1 AND NumDays <@ReportIncAgeBin2, 1, 0))
	, Bin3 = SUM(IIF(NumDays>=@ReportIncAgeBin2 AND NumDays <@ReportIncAgeBin3, 1, 0))
	, Bin4 = SUM(IIF(NumDays>=@ReportIncAgeBin3, 1, 0))
FROM
	IncAgeGereed
GROUP BY
	[Date]
)

--SELECT * FROM IncCountGereed ORDER BY [Date]

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

	, [Open] = ISNULL(AantalOpen,0)
	, [Gereed] = ISNULL(AantalGereed,0)
	, OpenBin1 = ISNULL(O.Bin1,0)
	, OpenBin2 = ISNULL(O.Bin2,0)
	, OpenBin3 = ISNULL(O.Bin3,0)
	, OpenBin4 = ISNULL(O.Bin4,0)
	, GereedBin1 = ISNULL(G.Bin1,0)
	, GereedBin2 = ISNULL(G.Bin2,0)
	, GereedBin3 = ISNULL(G.Bin3,0)
	, GereedBin4 = ISNULL(G.Bin4,0)

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

	, OpenBin1EndofInterval = FIRST_VALUE(O.Bin1) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, OpenBin2EndofInterval = FIRST_VALUE(O.Bin2) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, OpenBin3EndofInterval = FIRST_VALUE(O.Bin3) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, OpenBin4EndofInterval = FIRST_VALUE(O.Bin4) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)

	, GereedBin1EndofInterval = FIRST_VALUE(G.Bin1) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, GereedBin2EndofInterval = FIRST_VALUE(G.Bin2) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, GereedBin3EndofInterval = FIRST_VALUE(G.Bin3) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
	, GereedBin4EndofInterval = FIRST_VALUE(G.Bin4) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												ORDER BY D.[Date] DESC)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN IncCountOpen O ON D.[Date] = O.[Date]
	LEFT OUTER JOIN IncCountGereed G ON D.[Date] = G.[Date]
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
	, [Open] = MAX(OpenEndofInterval)
	, OpenBin1 = MAX(OpenBin1EndofInterval)
	, OpenBin2 = MAX(OpenBin2EndofInterval)
	, OpenBin3 = MAX(OpenBin3EndofInterval)
	, OpenBin4 = MAX(OpenBin4EndofInterval)
	, Gereed = MAX(GereedEndofInterval)
	, GereedBin1 = MAX(GereedBin1EndofInterval)
	, GereedBin2 = MAX(GereedBin2EndofInterval)
	, GereedBin3 = MAX(GereedBin3EndofInterval)
	, GereedBin4 = MAX(GereedBin4EndofInterval)

-- , MinOpen = MAX(OpenMinofInterval)
-- , MaxOpen = MAX(OpenMaxofInterval)
-- , AvgOpen = MAX(OpenAVGofInterval)

-- , MinGereed = MAX(GereedMinofInterval)
-- , MaxGereed = MAX(GereedMaxofInterval)
-- , AvgGereed = MAX(GereedAVGofInterval)
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
)

SELECT
	*
FROM
	EndResult
ORDER BY
	DWInterval

END

/*
EXEC [dbo].[Inc_Age_per_Interval_v02]
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

-- Bins moeten naar MDS
, @ReportIncAgeBin1 = 3 -- Bepaalt de eerste leeftijdscategorie voor de openstaande meldingen
, @ReportIncAgeBin2 = 5 -- Bepaalt de tweede leeftijdscategorie voor de openstaande meldingen
, @ReportIncAgeBin3 = 10 -- Bepaalt de derde leeftijdscategorie voor de openstaande meldingen
*/