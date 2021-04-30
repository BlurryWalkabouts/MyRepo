
CREATE PROCEDURE [dbo].[Inc_en_Cha_Aantal_per_Interval_v01] 
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

, @ChaTypeSTD AS nvarchar(max) = 'All'
, @Coordinator AS nvarchar(max) = 'Servicedesk'
, @ChaTemplate AS nvarchar(max) = 'All'
, @CurrentPhaseSTD AS nvarchar(max) = 'All'
AS

BEGIN

/* Query om aantal aangemelde incidenten en wijzigingen per interval te berekenen, om deze vervolgens
	van elkaar te trekken. Te filteren op o.a klant, OperatorGroup, EntryType, IncidentType enz. 

	Geschreven door Mark Krijtenberg */

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
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
WHERE 1=1
	AND (ClosureDate >= @ReportStartDate OR ClosureDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Gefilterde changes */
SELECT
	Ch.Change_Id
	, C.Fullname
	, OperatorGroupSTD
	, RequestDate
	, Ch.AuthorizationDate
	, Ch.ImplDateExtChange
	, Ch.EndDateExtChange
	, Ch.CompletionDate
	, Ch.ClosureDate
INTO
	#FilteredChanges
FROM
	Fact.Change Ch
	LEFT OUTER JOIN Dim.Customer C ON Ch.CustomerKey = C.CustomerKey
	LEFT OUTER JOIN Dim.OperatorGroup OG ON Ch.OperatorGroupKey = OG.OperatorGroupKey
	LEFT OUTER JOIN Dim.[Caller] Ca ON Ca.CallerKey = Ch.CallerKey
WHERE 1=1
	AND ('All' IN(@EndUserService) OR C.EndUserServiceType IN(SELECT * FROM [fn_CSVToTable](@EndUserService)))
	AND ('All' IN(@SysAdminService) OR C.SysAdminServiceType IN(SELECT * FROM [fn_CSVToTable](@SysAdminService)))
	AND ('All' IN(@IncCategory) OR Ch.Category IN(SELECT * FROM [fn_CSVToTable](@IncCategory)))
	AND ('All' IN(@IncSubcategory) OR Ch.Subcategory IN(SELECT * FROM [fn_CSVToTable](@IncSubcategory)))

	AND Ch.CustomerKey IN(SELECT * FROM [fn_CSVToTable](@Customer))
	AND ('All' IN(@CustomerGroup) OR C.CustomerGroup IN(SELECT * FROM [fn_CSVToTable](@CustomerGroup)))
	AND ('All' IN(@CallerBranch) OR CA.CallerBranch IN(SELECT * FROM [fn_CSVToTable](@CallerBranch)))

	AND ('All' IN(@ChaTypeSTD) OR Ch.TypeSTD IN(SELECT * FROM [fn_CSVToTable](@ChaTypeSTD)))
	AND ('All' IN(@Coordinator) OR Coordinator IN(SELECT * FROM [fn_CSVToTable](@Coordinator)))
	AND ('All' IN(@ChaTemplate) OR Template IN(SELECT * FROM [fn_CSVToTable](@ChaTemplate)))
	AND ('All' IN(@CurrentPhaseSTD) OR CurrentPhaseSTD IN(SELECT * FROM [fn_CSVToTable](@CurrentPhaseSTD)))

	AND (Ch.ClosureDate >= @ReportStartDate OR Ch.ClosureDate IS NULL)
	AND RequestDate <= @ReportEndDate

--SELECT * FROM #FilteredChanges

/* Aantal aangemelde meldingen */
;WITH IncCreated AS
(
SELECT 
	IncidentDate
	, AantalAangemeldIncident = COUNT(Incident_Id)
FROM
	#FilteredIncidents
GROUP BY
	IncidentDate
)
 
--SELECT * FROM IncCreated ORDER BY IncidentDate

/* Aantal aangemelde meldingen */
, ChaCreated AS
(
SELECT 
	RequestDate
	, AantalAangemeldChange = COUNT(Change_Id)
FROM
	#FilteredChanges
GROUP BY
	RequestDate
)
 
--SELECT * FROM ChaCreated ORDER BY IncidentDate

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

	, IncidentAangemeld = ISNULL(AantalAangemeldIncident,0)
	, ActiefIntervalIncident = MAX(IIF(AantalAangemeldIncident IS NULL,NULL,1)) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
	, ChangeAangemeld = ISNULL(AantalAangemeldChange,0)
	, ActiefIntervalChange = MAX(IIF(AantalAangemeldChange IS NULL,NULL,1)) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN IncCreated ON D.[Date] = IncidentDate
	LEFT OUTER JOIN ChaCreated ON D.[Date] = RequestDate
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
	, IncidentAangemeld = SUM(IncidentAangemeld)
	, ChangeAangemeld = SUM(ChangeAangemeld)
	, GecorrigeerdAantalIncidenten = SUM(IncidentAangemeld) - SUM(ChangeAangemeld)
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
	, ActiefIntervalIncident
	, ActiefIntervalChange
)

SELECT
	*
FROM
	EndResult
ORDER BY
	DWInterval

END

/*
EXEC [dbo].[Inc_en_Cha_Aantal_per_interval_v01]
@Customer = '317'
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

, @ChaTypeSTD = 'All'
, @Coordinator = 'Servicedesk'
, @ChaTemplate = 'All'
, @CurrentPhaseSTD = 'All'
*/