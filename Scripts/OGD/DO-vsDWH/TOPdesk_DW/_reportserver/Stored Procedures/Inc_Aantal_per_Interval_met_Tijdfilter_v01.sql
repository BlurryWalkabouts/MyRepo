
CREATE PROCEDURE [dbo].[Inc_Aantal_per_Interval_met_Tijdfilter_v01]
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
	, DOpen.Holiday AS HolidayOpen
	, DClose.Holiday AS HolidayClosed
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
	IncidentDate
	, AantalAangemeld = COUNT(Incident_Id)
FROM
	#FilteredIncidents
WHERE 1=1
	AND (DOpen IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR (DOpen NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND 8 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 1))
	AND (CAST(TOpen AS time) >=
			CASE
				WHEN DOpen <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 0 THEN @StartTime
				WHEN DOpen <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 0 THEN @StartTime
				WHEN DOpen <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 1 THEN @StartTimeWeekend	-- dag is feestdag
				WHEN DOpen <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 1 THEN @StartTime
				WHEN DOpen BETWEEN 6 AND 7 THEN @StartTimeWeekend											-- dag is in een weekend
			END)
	AND (CAST(TOpen AS time) <=
			CASE
				WHEN DOpen <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 0 THEN @EndTime
				WHEN DOpen <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 0 THEN @EndTime
				WHEN DOpen <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 1 THEN @EndTimeWeekend		-- dag is feestdag
				WHEN DOpen <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayOpen = 1 THEN @EndTime
				WHEN DOpen BETWEEN 6 AND 7 THEN @EndTimeWeekend												-- dag is in een weekend
			END)
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
	AND (DClose IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) OR (DClose NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND 8 IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 1))
	AND (CAST(TClose AS time) >=
			CASE
				WHEN DClose <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 0 THEN @StartTime
				WHEN DClose <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 0 THEN @StartTime
				WHEN DClose <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 1 THEN @StartTimeWeekend	-- dag is feestdag
				WHEN DClose <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 1 THEN @StartTime
				WHEN DClose BETWEEN 6 AND 7 THEN @StartTimeWeekend												-- dag is in een weekend
			END)
	AND (CAST(TClose AS time) <=
			CASE
				WHEN DClose <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 0 THEN @EndTime
				WHEN DClose <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 0 THEN @EndTime
				WHEN DClose <6 AND '8' IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 1 THEN @EndTimeWeekend		-- dag is feestdag
				WHEN DClose <6 AND '8' NOT IN(SELECT * FROM [fn_CSVToTable](@DayOfWeek)) AND HolidayClosed = 1 THEN @EndTime
				WHEN DClose BETWEEN 6 AND 7 THEN @EndTimeWeekend												-- dag is in een weekend
			END)
GROUP BY
	ClosureDate
)

--SELECT * FROM IncClosed --ORDER BY Date

/* Alles samenvoegen tot een tabel */
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

	, ActiefInterval = MAX(IIF(AantalAangemeld IS NULL,NULL,1)) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN IncCreated Cr ON D.[Date] = Cr.IncidentDate
	LEFT OUTER JOIN IncClosed Cl ON D.[Date] = Cl.ClosureDate
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
EXEC [dbo].[Inc_Aantal_per_Interval_met_Tijdfilter_v01]
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