
CREATE PROCEDURE [dbo].[Inc_Aantal_per_Halfuur_met_Tijdfilter_v01] 
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

, @DayOfWeek AS nvarchar(max) -- Kies de dag(en) die je wil meenemen in het resultaat (ma = 1)
, @StartTime AS time = '0:00'
, @EndTime AS time = '23:59:59'
, @StartTimeWeekend AS time = '0:00'
, @EndTimeWeekend AS time = '23:59:59'
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
	, TOpen.Time_half_hour_of_day AS TOpen
	, DOpen.[DayOfWeek] AS DOpen
	, TClose.Time_half_hour_of_day AS TClose
	, DClose.[DayOfWeek] AS DClose
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
	LEFT OUTER JOIN Dim.[Time] TOpen ON CreationTime = TOpen.[Time]
	LEFT OUTER JOIN Dim.[Date] DOpen ON CreationDate = DOpen.[Date]
	LEFT OUTER JOIN Dim.[Time] TClose ON ClosureTime = TClose.[Time]
	LEFT OUTER JOIN Dim.[Date] DClose ON ClosureDate = DClose.[Date]
WHERE 1=1
	AND (ClosureDate >= @ReportStartDate OR ClosureDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Aantal aangemelde meldingen */
;WITH IncCreated AS
(
SELECT 
	TOpen
	, AantalAangemeld = COUNT(Incident_Id)
FROM
	#FilteredIncidents
WHERE 1=1
	AND (DOpen IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 0 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)))
	AND (CAST(TOpen AS time) >=
			CASE
				WHEN DOpen <6 THEN @StartTime				-- dag is een weekdag
				WHEN DOpen >=6 THEN @StartTimeWeekend	-- dag is in een weekend
			END)
	AND (CAST(TOpen AS time) <=
			CASE
				WHEN DOpen <6 THEN @EndTime				-- dag is een weekdag
				WHEN DOpen >=6 THEN @EndTimeWeekend		-- dag is in een weekend
			END)
GROUP BY
	TOpen
)
 
--SELECT * FROM IncCreated ORDER BY IncidentDate

/* Aantal afgemelde meldingen */
, IncClosed AS
(
SELECT 
	TClose
	, AantalGesloten = COUNT(Incident_Id)
FROM 
	#FilteredIncidents
WHERE 1=1
	AND ClosureDate IS NOT NULL
	AND (DClose IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 0 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)))
	AND (CAST(TClose AS time) >=
			CASE
				WHEN DClose <6 THEN @StartTime				-- dag is een weekdag
				WHEN DClose >=6 THEN @StartTimeWeekend		-- dag is in een weekend
			END)
	AND (CAST(TClose AS time) <=
			CASE
				WHEN DClose <6 THEN @EndTime					-- dag is een weekdag
				WHEN DClose >=6 THEN @EndTimeWeekend		-- dag is in een weekend
			END)
GROUP BY
	TClose
)

--SELECT * FROM IncClosed --ORDER BY Date

/* Alles samenvoegen tot een tabel */
, CountsPerTime AS
(
SELECT
	T.Time_half_hour_of_day
	, Aangemeld = MAX(ISNULL(AantalAangemeld,0))
	, Afgemeld = MAX(ISNULL(AantalGesloten,0))
FROM
	Dim.[Time] T
	LEFT OUTER JOIN IncCreated Cr ON T.Time_half_hour_of_day = Cr.TOpen
	LEFT OUTER JOIN IncClosed Cl ON T.Time_half_hour_of_day = Cl.TClose
WHERE 1=1
	AND T.Time_half_hour_of_day IS NOT NULL
	AND T.Time_half_hour_of_day >=
		CASE 
			WHEN 1 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 2 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 3 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 4 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 5 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) THEN @StartTime
			WHEN 6 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 7 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) THEN @StartTimeWeekend
			WHEN 0 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND (@StartTimeWeekend <= @StartTime) THEN @StartTimeWeekend
			WHEN 0 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND (@StartTimeWeekend >= @StartTime) THEN @StartTime
		END
	AND T.Time_half_hour_of_day <=
		CASE 
			WHEN 1 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 2 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 3 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 4 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 5 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) THEN @EndTime
			WHEN 6 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR 7 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) THEN @EndTimeWeekend
			WHEN 0 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND (@EndTimeWeekend >= @EndTime) THEN @EndTimeWeekend
			WHEN 0 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND (@EndTimeWeekend <= @EndTime) THEN @EndTime
		END
GROUP BY
	T.Time_half_hour_of_day
)

SELECT
	*
FROM
	CountsPerTime
ORDER BY
	Time_half_hour_of_day

END

/*
EXEC [dbo].[Inc_Aantal_per_Halfuur_met_Tijdfilter_v01]
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

, @DayOfWeek = '1' -- Kies de dag(en) die je wil meenemen in het resultaat (ma = 1)
, @StartTime = '0:00'
, @EndTime = '23:59:59'
, @StartTimeWeekend = '0:00'
, @EndTimeWeekend = '23:59:59'
*/