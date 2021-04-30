
CREATE PROCEDURE [dbo].[Inc_Aantal_per_Interval_en_Cat_Subcategory_v01] 
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

/* Query om het aantal aangemelde, afgemelde, openstaande en gereedgemelde meldingen
	te bepalen per subcategorie over de laatste maand 

	Geschreven door Wouter Gielen, Mark Krijtenberg */

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

--SELECT * FROM #FilteredIncidents

/* Alle mogelijke subcategorieen */
SELECT DISTINCT
	Subcategory 
	, Category
INTO
	#Subcategories
FROM
--	#FilteredIncidents
	Fact.Incident I
	LEFT OUTER JOIN Dim.Customer C ON I.CustomerKey = C.CustomerKey
WHERE 1=1
	AND ('All' IN(@CustomerGroup) OR C.CustomerGroup IN(SELECT * FROM [fn_CSVToTable](@CustomerGroup)))
	AND I.CustomerKey IN(SELECT * FROM [fn_CSVToTable](@Customer))
	AND ('All' IN(@IncCategory) OR I.Category IN(SELECT * FROM [fn_CSVToTable](@IncCategory)))
	AND ('All' IN(@IncSubcategory) OR I.Subcategory IN(SELECT * FROM [fn_CSVToTable](@IncSubcategory)))
	AND ('All' IN(@SysAdminService) OR C.SysAdminServiceType IN(SELECT * FROM [fn_CSVToTable](@SysAdminService)))
	AND ('All' IN(@EndUserService) OR C.EndUserServiceType IN(SELECT * FROM [fn_CSVToTable](@EndUserService)))

--SELECT * FROM #Subcategories ORDER BY Subcategory

/* Aantal aangemelde meldingen */
;WITH IncCreated AS
(
SELECT 
	IncidentDate
	, Category
	, Subcategory 
	, AantalAangemeld = COUNT(Incident_Id)
FROM
	#FilteredIncidents
GROUP BY
	IncidentDate
	, Category
	, Subcategory
)
 
--SELECT * FROM IncCreated ORDER BY IncidentDate

/* Aantal afgemelde meldingen */
, IncClosed AS
(
SELECT 
	ClosureDate
	, Category
	, Subcategory
	, AantalGesloten = COUNT(Incident_Id)
FROM 
	#FilteredIncidents
WHERE 1=1
	AND ClosureDate IS NOT NULL
GROUP BY
	ClosureDate
	, Category
	, Subcategory
)

--SELECT * FROM IncClosed --ORDER BY Date

/* Aantal openstaande meldingen */
, IncOpen AS
(
SELECT
	D.[Date]
	, Category
	, Subcategory
	, AantalOpen = COUNT(I.Incident_Id)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN #FilteredIncidents I ON I.IncidentDate <= D.[Date] AND (I.CompletionDate > D.[Date] OR I.CompletionDate IS NULL)
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
GROUP BY
	D.[Date]
	, Category
	, Subcategory
)

--SELECT * FROM IncOpen --ORDER BY Date

/* Aantal gereedgemelde, niet afgemelde meldingen */
, IncGereed AS
(
SELECT
	D.[Date]
	, Category
	, Subcategory
	, AantalGereed = COUNT(I.Incident_Id)
FROM
	Dim.[Date] D
	LEFT OUTER JOIN #FilteredIncidents I ON I.CompletionDate <= D.[Date] AND (I.ClosureDate > D.[Date] OR I.ClosureDate IS NULL)
WHERE 1=1
	AND D.[Date] BETWEEN @ReportStartDate AND @ReportEndDate
GROUP BY
	D.[Date]
	, Category
	, Subcategory
)

--SELECT * FROM IncGereed --ORDER BY Date

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

	, S.Category
	, S.Subcategory

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
												, S.Subcategory
												ORDER BY D.[Date] DESC)
	, GereedEndofInterval = FIRST_VALUE(AantalGereed) OVER (PARTITION BY CASE @ReportInterval
													WHEN 'Month' THEN D.DWMonthNumber
													WHEN 'Week' THEN D.DWWeekNumber
													WHEN 'Day' THEN D.DateKey
												END
												, S.Subcategory
												ORDER BY D.[Date] DESC)
			
FROM
	Dim.[Date] D
	CROSS JOIN #Subcategories S
	LEFT OUTER JOIN IncCreated Cr ON D.[Date] = Cr.IncidentDate AND Cr.Subcategory = S.Subcategory AND Cr.Category = S.Category
	LEFT OUTER JOIN IncClosed Cl ON D.[Date] = Cl.ClosureDate AND Cl.Subcategory = S.Subcategory AND Cl.Category = S.Category
	LEFT OUTER JOIN IncOpen O ON D.[Date] = O.[Date] AND O.Subcategory = S.Subcategory AND O.Category = S.Category
	LEFT OUTER JOIN IncGereed G ON D.[Date] = G.[Date] AND G.Subcategory = S.Subcategory AND G.Category = S.Category
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

	, Category
	, Subcategory
	, CatAndSubCat = Subcategory + ' (' + Category + ')'

	, Aangemeld = SUM(Aangemeld)
--	, AangemeldNull = SUM(AangemeldNull)
	, Afgemeld = SUM(Afgemeld)
	, [Open] = MAX(ISNULL(OpenEndofInterval,0))
	, Gereed = MAX(ISNULL(GereedEndofInterval,0))
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
	, Category
	, Subcategory
)

SELECT
	*
FROM
	EndResult
ORDER BY
	DWInterval
	, Category
	, Subcategory

END

/*
EXEC [dbo].[Inc_Aantal_per_Interval_en_Cat_Subcategory_v01]
@Customer = '10'
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