
CREATE PROCEDURE [dbo].[Inc_Aging_Mailresponse_per_Incident_v01] 
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
, @ReportAgingLimit AS int = 10 -- Bepaalt vanaf welk aantal minuten meldingen in de aging lijst terugkomen
AS

BEGIN

/*	Query om de meldingen met het grootste verschil tussen automatische import en opslaan door medewerker op te halen.

	Geschreven door Mark Krijtenberg */

/* Variabelen */
DECLARE @ReportStartDate AS datetime =	dbo.ReportStartDate(@ReportDate,@ReportPeriod,@ReportInterval)
DECLARE @ReportEndDate AS datetime = DATEADD(MI,-1,DATEADD(day,1,CAST(@ReportDate AS smalldatetime)))
-- Dit zorgt er voor dat de periode incl de gekozen rapport datum wordt ipv tot het begin van die dag. De periode loopt dus t/m 23:59 van de gekozen dag

/* Gefilterde meldingen */
SELECT
	Incident_Id
	, IncidentNumber
	, Fullname
	, CallerName
	, IncidentDescription
	, IncidentDate
	, Created = CONCAT(IncidentDate, ' ', IncidentTime)
	, Saved = CONCAT(CreationDate,' ', CreationTime)
	, SupportWindow_ID
	, S.MailResponseTimeValue
INTO
	#FilteredIncidents
FROM
	dbo.tvf_FilteredIncidents (@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod) I
	LEFT OUTER JOIN Dim.vwSLA S ON S.Name = I.IncSLA
WHERE 1=1
	AND EntryTypeSTD = 'E-mail'
	AND (CreationDate >= @ReportStartDate OR CreationDate IS NULL)
	AND IncidentDate <= @ReportEndDate

--SELECT * FROM #FilteredIncidents

/* Leeftijd van individuele openstaande meldingen per dag */
;WITH TijdBerekening AS
(
SELECT
	Incident_Id
	, IncidentNumber
	, Fullname
	, CallerName
	, IncidentDescription
	, IncidentDate
	, Created
	, Saved
	, AantalMinuten = DATEDIFF(mi, Created, Saved)
	, AantalWerkMinuten = dbo.TimeSpan(Created,Saved,SupportWindow_ID) / 60
	, MailResponseTimeValue
FROM
	#FilteredIncidents
WHERE 1=1
	AND Created <= Saved
	AND DATEDIFF(mi, Created, Saved) > @ReportAgingLimit
)

--SELECT * FROM TijdBerekening

SELECT
	IncidentNumber AS Meldingnummer
	, Fullname AS Klant
	, CallerName AS Aanmelder
	, IncidentDescription AS Omschrijving
	, IncidentDate
	, Created
	, Saved
	, AantalMinuten
	, AantalWerkMinuten
	, MailResponseTimeValue
FROM
	TijdBerekening
ORDER BY
	AantalMinuten DESC
	, AantalWerkMinuten DESC

END

/*
EXEC [dbo].[Inc_Aging_Mailresponse_per_incident_v01]
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
, @ReportAgingLimit = 10 -- Bepaalt vanaf welk aantal minuten meldingen in de aging lijst terugkomen
*/