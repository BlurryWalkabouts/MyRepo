/****** Object:  DatabaseRole [BI-Basis]    Script Date: 5/3/2017 10:33:43 AM ******/
CREATE ROLE [BI-Basis]
GO
/****** Object:  Schema [Dim]    Script Date: 5/3/2017 10:33:43 AM ******/
CREATE SCHEMA [Dim]
GO
/****** Object:  Schema [Fact]    Script Date: 5/3/2017 10:33:43 AM ******/
CREATE SCHEMA [Fact]
GO
/****** Object:  Schema [log]    Script Date: 5/3/2017 10:33:43 AM ******/
CREATE SCHEMA [log]
GO
/****** Object:  Table [Dim].[Caller]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Caller](
	[CallerKey] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[CallerName] [nvarchar](255) NULL,
	[CallerEmail] [nvarchar](255) NULL,
	[CallerTelephoneNumber] [nvarchar](255) NULL,
	[CallerTelephoneNumberSTD] [varchar](32) NULL,
	[CallerMobileNumber] [nvarchar](255) NULL,
	[CallerMobileNumberSTD] [varchar](32) NULL,
	[Department] [nvarchar](255) NULL,
	[CallerBranch] [nvarchar](255) NULL,
	[CallerCity] [nvarchar](255) NULL,
	[CallerLocation] [nvarchar](255) NULL,
	[CallerRegion] [nvarchar](255) NULL,
	[CallerGender] [nvarchar](255) NULL,
 CONSTRAINT [PK_Caller] PRIMARY KEY CLUSTERED 
(
	[CallerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[Call]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Call](
	[CallSummaryID] [bigint] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[StartDateKey] [char](8) NULL,
	[StartTimeKey] [int] NULL,
	[InQueueDateKey] [int] NULL,
	[InQueueTimeKey] [int] NULL,
	[AcceptedDateKey] [int] NULL,
	[AcceptedTimeKey] [int] NULL,
	[EndDateKey] [int] NULL,
	[EndTimeKey] [int] NULL,
	[UCCName] [varchar](255) NULL,
	[Caller] [varchar](255) NULL,
	[StartTime] [datetime] NULL,
	[InQueueTime] [datetime] NULL,
	[AcceptedTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Accepted] [bit] NULL,
	[CallDuration] [int] NULL,
	[CallTotalDuration] [int] NULL,
	[QueueDuration] [int] NULL,
	[SkillChosen] [varchar](50) NULL,
	[InitialAgent] [varchar](255) NULL,
	[Handled] [bit] NULL,
	[DWDateCreated] [datetime] NULL,
 CONSTRAINT [PK_Call] PRIMARY KEY CLUSTERED 
(
	[CallSummaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[AgentName_Email]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[AgentName_Email]
AS
     WITH DistinctIA
          AS (

          /* selecteer alle distinct agents*/
          SELECT DISTINCT
                 initialAgent
          FROM Fact.Call C
          WHERE initialAgent IS NOT NULL
                AND initialAgent <> ''
                AND (initialAgent LIKE '%@ogd.nl'
                     OR initialAgent LIKE '%@ogd.nl;user=phone')),
          LatestAgent
          AS (

/*bij dubbele emailadressen nemen we de meest recente versie
idem voor telefoonnummers*/
          SELECT *
          FROM
          (
              SELECT DISTINCT
                     CallerKey
                   , callername
                   , CallerEmail
                   , CallerTelephoneNumber
                   , ROW_NUMBER() OVER(PARTITION BY CallerEmail ORDER BY CallerKey DESC) AS RN1
                   , ROW_NUMBER() OVER(PARTITION BY CallerTelephoneNumber ORDER BY CallerKey DESC) AS RN2
              FROM dim.caller
              WHERE CallerEmail LIKE '%@%'
          ) X
          WHERE RN1 = 1
                AND RN2 = 1),
          result
          AS (SELECT initialAgent
                   , dc.CallerName AS AgentNameViaTel
                   , c2.CallerName AS AgentNameViaEmail
                   , c2.CallerEmail AS AgentEmailViaEmail
                   , CASE
                         WHEN initialAgent LIKE 'sip:+3188653%'
                         THEN CASE
                                  WHEN dc.CallerEmail IS NULL
                                  THEN
		
                              /*nummers waar geen emailadres bij gevonden kan worden in dim_Caller?*/
                              CASE initialAgent
                                  WHEN 'sip:+31886532000@ogd.nl;user=phone'
                                  THEN 'receptie@ogd.nl'
                                  WHEN 'sip:+31886532002@ogd.nl;user=phone'
                                  THEN 'terbiumservicedesk@ogd.nl'
                                  WHEN 'sip:+31886532431@ogd.nl;user=phone'
                                  THEN 'jerome.vincendon@ogd.nl'
                                  WHEN 'sip:+31886532468@ogd.nl;user=phone'
                                  THEN 'wieshaal.jhinnoe@ogd.nl'
                                  WHEN 'sip:+31886532508@ogd.nl;user=phone'
                                  THEN 'gerrit.eisma@ogd.nl'
                                  WHEN 'sip:+31886532554@ogd.nl;user=phone'
                                  THEN 'stefan.janssen@ogd.nl'
                                  ELSE ''
                              END
                                  ELSE dc.CallerEmail
                              END
                     END AS AgentEmailViaTel
              FROM DistinctIA
                   LEFT OUTER JOIN LatestAgent AS dc ON initialAgent LIKE 'sip:+3188653%'
                                                        AND SUBSTRING(initialAgent, 5, 12) = dc.CallerTelephoneNumber
                   LEFT OUTER JOIN LatestAgent AS c2 ON initialAgent = 'sip:'+c2.CallerEmail
                                                        AND isnull(c2.CallerEmail, '') <> '')
          SELECT COALESCE(AgentNameViaTel, AgentNameViaEmail) AS AgentName
               , COALESCE(AgentEmailViaTel, AgentEmailViaEmail) AS AgentEmail
          FROM result;
GO
/****** Object:  Table [Dim].[Users]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Users](
	[Code] [nvarchar](250) NOT NULL,
	[Name] [nvarchar](250) NULL,
	[SecurityClearance] [nvarchar](250) NULL,
	[LastChgDateTime] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[Dim.vwUser]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[Dim.vwUser]
AS
     SELECT Name
		  , SecurityClearance
     FROM Dim.Users;
GO
/****** Object:  Table [Dim].[Date]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Date](
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[DayOfWeek] [smallint] NULL,
	[NL_Weekdag] [varchar](10) NULL,
	[EN_Weekday] [varchar](10) NULL,
	[DayInMonth] [smallint] NULL,
	[DayOfYear] [smallint] NULL,
	[WeekOfYear] [tinyint] NULL,
	[Weeknumber] [tinyint] NULL,
	[EN_Month] [varchar](10) NULL,
	[NL_Maand] [varchar](10) NULL,
	[MonthOfYear] [tinyint] NULL,
	[CalendarQuarter] [tinyint] NULL,
	[CalendarYear] [smallint] NULL,
	[DWDayNumber] [smallint] NULL,
	[CalendarSemester] [tinyint] NULL,
	[DWWeekNumber] [smallint] NULL,
	[NL_WeekdayShort] [nchar](2) NULL,
	[NL_MonthShort] [varchar](8) NULL,
	[WeekStartYear] [smallint] NULL,
	[WeekStartDate] [date] NULL,
	[WeekYear] [smallint] NULL,
	[DWMonthNumber] [smallint] NULL,
	[Holiday] [bit] NULL,
	[DWWorkDayNumber] [smallint] NULL,
 CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwDate]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [Dim].[vwDate]
AS

SELECT 
	DateKey
	, [DayOfWeek]
	, NL_Weekdag
	, EN_Weekday
	, DayInMonth
	, [DayOfYear]
	, WeekOfYear
	, Weeknumber
	, EN_Month
	, NL_Maand
	, MonthOfYear
	, CalendarQuarter
	, CalendarYear
	, DWDayNumber
	, CalendarSemester
	, DWWeekNumber
	, NL_WeekdayShort
	, NL_MonthShort
	, WeekStartYear
	, [Date]
	, WeekStartDate
	, WeekYear
	, DWMonthNumber
	, Holiday
	, DWWorkDayNumber
	, DayComparedToToday = DATEDIFF(DD, CAST(GETDATE() AS date), [Date])
	, WeekComparedToToday = DATEDIFF(WW, DATEADD(DAY,-1,GETDATE()), DATEADD(DAY,-1,[Date]))
	, MonthComparedToToday = DATEDIFF(MM, CAST(GETDATE() AS date), [Date])
FROM
	Dim.[Date]
GO
/****** Object:  Table [Dim].[Time]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Time](
	[TimeKey] [int] NOT NULL,
	[minute_of_day] [int] NULL,
	[hour_of_day_24] [decimal](38, 0) NULL,
	[hour_of_day_12] [decimal](38, 0) NULL,
	[am_pm] [nvarchar](100) NULL,
	[minute_of_hour] [decimal](38, 0) NULL,
	[half_hour] [decimal](38, 0) NULL,
	[half_hour_of_day] [decimal](38, 0) NULL,
	[quarter_hour] [decimal](38, 0) NULL,
	[quarter_hour_of_day] [decimal](38, 0) NULL,
	[Time_half_hour_of_day] [time](0) NULL,
	[Time] [time](0) NULL,
 CONSTRAINT [PK_Time] PRIMARY KEY CLUSTERED 
(
	[TimeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwDateTime]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [Dim].[vwDateTime]
AS

SELECT
	CAST(CAST([Date] AS char(10)) + ' ' + CAST([Time] AS char(8)) AS datetime2(3)) AS datetime
	, D.[Date]
	, T.[Time]
FROM
	Dim.[Date] D
	CROSS JOIN Dim.[Time] T
GO
/****** Object:  View [Dim].[vwDateTimeHalfHours]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [Dim].[vwDateTimeHalfHours]
AS
SELECT
	*
FROM
	Dim.[Date]
	, Dim.[Time] 
WHERE 1=1
	AND [Time] IS NOT NULL
	AND DATEPART(MI,[Time]) % 30 = 0
	AND DATEPART(ss,[Time]) = 0


GO
/****** Object:  View [Dim].[vwDateTimeMovedtoMetadata]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE view [Dim].[vwDateTimeMovedtoMetadata] as 
(
select 
	cast( cast(date as char(10)) + ' ' + cast(time as char(8)) as datetime2(3)) as DateTime
	,D.Date
	,T.Time
from dim.Date D
cross join dim.Time T
)
GO
/****** Object:  Table [Dim].[Customer]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Customer](
	-- PseudoKey
	[CustomerKey] [int] IDENTITY(1,1) NOT NULL,

	-- Customer Generic Identifier
	[CustomerNumber] [nvarchar](10) NULL,
	[Fullname] [nvarchar](100) NULL,
	[CustomerActive] [bit] NULL,

	-- Addres Data
	[Postcode] [nvarchar](15) NULL,
	[Address] [nvarchar](70) NULL,
	[City] [nvarchar](30) NULL,
	[Country] [nvarchar](30) NULL,
	[TelephoneNumber] [nvarchar](100) NULL,

	-- Customer Characteristics
	[Sector] [nvarchar](100) NULL,
	[SubSector] [nvarchar](100) NULL,
	[CustomerCompanySize] [nvarchar](25) NULL,
	[ServiceDeliveryManager] [nvarchar](100) NULL,
	[AccountManagerKey] [int] NOT NULL,
	[AccountManagerName] [nvarchar](255) NULL,
	[OutsourcingType] [nvarchar](100) NULL,
	[ServicesType] [nvarchar](100) NULL,
	[ServiceDeskServiceType] [nvarchar](250) NULL,
	[SysAdminServiceType] [nvarchar](250) NULL,

	-- OGD Interal Assignment
	[CustomerTeam] [nvarchar](255) NULL,
	[SysAdminTeam] [nvarchar](255) NULL,
	[ServiceDeskTeam] [nvarchar](255) NULL,

	-- Contract Data
	[SLA] [nvarchar](250) NULL,
	[ExpIncLoad] [decimal](38, 0) NULL,
	[ExpChaLoad] [decimal](38, 0) NULL,
	[ExpCallLoad] [decimal](38, 0) NULL,
	[SupportWeekend] [decimal](38, 0) NULL,
	[RequiredSecurityClearance] [nvarchar](250) NULL,
	[SupportWindow] [nvarchar](250) NULL,
	[SupportWindow_ID] [int] NULL,
	[Contract_Users] [int] NULL,
	[Contract_FTE] [int] NULL,
	[Contract_Seats] [smallint] NULL,
	[Piket] [bit] NULL,
	[Archived] [decimal](38, 0) NULL,
	[OnBoardDate] [datetime2](3) NULL,
	[OffBoardDate] [datetime2](3) NULL,

	-- Unique id in source systems
	[LIFT_unid] [uniqueidentifier] NULL,

	-- Record validity
	[ValidFrom] [datetime2](3) NULL,
	[ValidTo] [datetime2](3) NULL,
	[Current] AS CASE WHEN ValidFrom <= GETUTCDATE() AND ValidTo >= GETUTCDATE() THEN 1 ELSE 0 END
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwExtWinLookup]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE view [Dim].[vwExtWinLookup] as
/*View voor het ExtensionWindow van Anywhere365 om inkomende telefoongesprekken te matchen met customers of callers uit het OGDW
De kolom CustomerFlag wordt toegevoegd omdat als medewerkers van een klant met een algemeen nummer naar buiten bellen de naam van
de klant zichtbaar moet zijn en niet de eeste persoon die gevonden wordt met het nummer.

Geschreven voor Wouter Gielen 15-10-15*/

select
	Fullname as Displayname
	,TelephoneNumber
	,null as MobileNumber
	,null as Email
	,1 as CustomerFlag
	from dim.Customer 

Union

Select
	CallerName
	,CallerTelephoneNumberSTD
	,CallerMobileNumberSTD
	,CallerEmail
	,0 as CustomerFlag
	from dim.Caller

--select * from dim.vwExtWinLookup order by CustomerFlag desc, Displayname
GO
/****** Object:  Table [Dim].[IncidentTypeSTD]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[IncidentTypeSTD](
	[IncidentTypeSTDKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [nvarchar](100) NULL,
 CONSTRAINT [PK_IncidentTypeSTD] PRIMARY KEY CLUSTERED 
(
	[IncidentTypeSTDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwIncidentTypeSTD]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Dim].[vwIncidentTypeSTD] as

SELECT 
	Name
FROM dim.IncidentTypeSTD

  /*
 Changed from MDS to Batch 

 SELECT 
      distinct      
      [TranslatedValue] as Name

  FROM [MDS].[mdm].[SourceTranslation]
  where TranslatedColumnName = 'IncidentTypeSTD'
 */
GO
/****** Object:  Table [Dim].[PrioritySTD]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[PrioritySTD](
	[PrioritySTDKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [nvarchar](100) NULL,
 CONSTRAINT [PK_PrioritySTD] PRIMARY KEY CLUSTERED 
(
	[PrioritySTDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwPrioritySTD]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Dim].[vwPrioritySTD] as

SELECT 
	Name
FROM dim.PrioritySTD

/*
 Changed from MDS to Batch 

SELECT 
      distinct      
      [TranslatedValue] as Name

  FROM [MDS].[mdm].[SourceTranslation]
  where TranslatedColumnName = 'PrioritySTD'
*/
GO
/****** Object:  Table [Dim].[SLA]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[SLA](
	[Code] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[CallResponseTimeValue] [decimal](9, 2) NULL,
	[CallResponseTimeRate] [decimal](9, 2) NULL,
	[CallDurationValue] [decimal](9, 2) NULL,
	[CallDurationRate] [decimal](9, 2) NULL,
	[MailResponseTimeValue] [decimal](9, 2) NULL,
	[MailResponseTimeRate] [decimal](9, 2) NULL,
	[IncidentFirstlineResolveRate] [decimal](9, 2) NULL,
	[IncidentVerstoringResolveRate] [decimal](9, 2) NULL,
	[IncidentFirstlineDuration] [decimal](9, 2) NULL,
	[IncidentSecondlineDuration] [decimal](9, 2) NULL,
	[StandardChangeDurationRate] [decimal](9, 2) NULL,
	[IncidentVerstoringP1ResolveRate] [decimal](9, 2) NULL,
	[IncidentVerstoringP2ResolveRate] [decimal](9, 2) NULL,
	[IncidentVerstoringP3ResolveRate] [decimal](9, 2) NULL,
	[IncidentAanvraagP5ResolveRate] [decimal](9, 2) NULL,
	[IncidentVraagP5ResolveRate] [decimal](9, 2) NULL,
	[KlachtResolveRate] [decimal](9, 2) NULL,
	[ProblemResolveRate] [decimal](9, 2) NULL,
	[ChangeAuthTimeValue] [decimal](9, 0) NULL,
	[ChangeAuthTimeRate] [decimal](9, 2) NULL,
	[ChangeClosingTimeValue] [decimal](9, 0) NULL,
	[ChangeClosingTimeRate] [decimal](9, 2) NULL,
	[LastChgDateTime] [datetime2](3) NOT NULL,
	[SLAKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
 CONSTRAINT [PK_SLA] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwSLA]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE view [Dim].[vwSLA] as 

select 
      [Code]
	  ,Name
      ,[CallResponseTimeValue]
      ,[CallResponseTimeRate]
      ,[CallDurationValue]
      ,[CallDurationRate]
	  ,[MailResponseTimeValue]
	  ,[MailResponseTimeRate]
	  ,[IncidentFirstlineResolveRate]
      ,[IncidentVerstoringResolveRate]
      ,[IncidentFirstlineDuration]
      ,[IncidentSecondlineDuration]
      ,[StandardChangeDurationRate]
      ,[IncidentVerstoringP1ResolveRate]
      ,[IncidentVerstoringP2ResolveRate]
      ,[IncidentVerstoringP3ResolveRate]
      ,[IncidentAanvraagP5ResolveRate]
      ,[IncidentVraagP5ResolveRate]
	  ,[KlachtResolveRate]
	  ,[ProblemResolveRate]
	  ,[ChangeAuthTimeValue]
	  ,[ChangeAuthTimeRate]
	  ,[ChangeClosingTimeValue]
	  ,[ChangeClosingTimeRate]
from dim.SLA

/*

 Changed from MDS to Batch 


SELECT 
      [Code]
	  ,Name
      ,[CallResponseTimeValue]
      ,[CallResponseTimeRate]
      ,[CallDurationValue]
      ,[CallDurationRate]
	  ,[MailResponseTimeValue]
	  ,[MailResponseTimeRate]
	  ,[IncidentFirstlineResolveRate]
      ,[IncidentVerstoringResolveRate]
      ,[IncidentFirstlineDuration]
      ,[IncidentSecondlineDuration]
      ,[StandardChangeDurationRate]
      ,[IncidentVerstoringP1ResolveRate]
      ,[IncidentVerstoringP2ResolveRate]
      ,[IncidentVerstoringP3ResolveRate]
      ,[IncidentAanvraagP5ResolveRate]
      ,[IncidentVraagP5ResolveRate]
	  ,[KlachtResolveRate]
	  ,[ProblemResolveRate]
	  ,[ChangeAuthTimeValue]
	  ,[ChangeAuthTimeRate]
	  ,[ChangeClosingTimeValue]
	  ,[ChangeClosingTimeRate]

  FROM [MDS].[mdm].[DimSLA]

*/
GO
/****** Object:  Table [Dim].[StatusSTD]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[StatusSTD](
	[StatusSTDKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Name] [nvarchar](100) NULL,
 CONSTRAINT [PK_StatusSTD] PRIMARY KEY CLUSTERED 
(
	[StatusSTDKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwStatusSTD]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Dim].[vwStatusSTD] as

SELECT 
      Name
FROM dim.StatusSTD

/*

 Changed from MDS to Batch 

 SELECT 
      distinct      
      [TranslatedValue] as Name
  FROM [MDS].[mdm].[SourceTranslation]
  where TranslatedColumnName = 'StatusSTD'
  */
GO
/****** Object:  Table [Fact].[Telefoniestoringen]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Telefoniestoringen](
	[Code] [int] NOT NULL,
	[StartDateKey] [int] NOT NULL,
	[EndDateKey] [int] NOT NULL,
	[StartTimeKey] [int] NOT NULL,
	[EndTimeKey] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[Classificatie_Name] [nvarchar](250) NULL,
	[Oorzaak_Name] [nvarchar](250) NULL,
	[Start] [datetime2](3) NOT NULL,
	[Eind] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Telefoniestoringen] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Dim].[vwTelefoniestoringen]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Dim].[vwTelefoniestoringen] as

-- StartDatum en EindDatum retourneren nu NULL. Dit zou nog gefixed moeten worden, maar als het goed is wordt deze view overbodig.
SELECT
	Code
	, [Name]
	, Classificatie_Name
	, Oorzaak_Name
	, StartDatum = NULL
	, EindDatum = NULL
	, [Start]
	, Eind
FROM
	Fact.Telefoniestoringen
/*
SELECT 
      [Code]
      ,[Name]
      ,[Classificatie_Name]
      ,[Oorzaak_Name]
	  ,[StartDatum]
	  ,[EindDatum]
      ,Dateadd(Minute,Datepart(minute,cast(Starttijd as time)),DATEADD(Hour,Datepart(hour,cast(Starttijd as time)),StartDatum)) as Start --Gedaan om de velden Startdatum en Starttijd samen te voegen , MDS ondersteund geen datumtijd veld
      ,Dateadd(Minute,Datepart(minute,cast(Eindtijd as time)),DATEADD(Hour,Datepart(hour,cast(EindTijd as time)),EindDatum)) as Eind --Gedaan om de velden Startdatum en Starttijd samen te voegen , MDS ondersteund geen datumtijd veld

  FROM [$(MDS)].[mdm].[DimTelefonieStoringen]
*/
GO
/****** Object:  View [Dim].[vwTimeMin]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [Dim].[vwTimeMin]
AS

SELECT
	*
FROM
	Dim.[Time]
WHERE 1=1
	AND DATEPART(SS, [Time]) = 0
GO
/****** Object:  Table [Fact].[WorkforceResourcesPerDay]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[WorkforceResourcesPerDay](
	[WorkforceResourcesPerDayKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Date] [datetime2](3) NULL,
	[CustomerGroup] [nvarchar](250) NULL,
	[Hours] [decimal](10, 2) NULL,
 CONSTRAINT [PK_WorkforceResourcesPerDay] PRIMARY KEY CLUSTERED 
(
	[WorkforceResourcesPerDayKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [Fact].[vwWorkforceResourcesPerDay]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Fact].[vwWorkforceResourcesPerDay] as
SELECT 
	   [Date]
      ,CustomerGroup
      ,[Hours]
FROM fact.WorkforceResourcesPerDay

/*

 Changed from MDS to Batch 

 SELECT [Date]
      ,[CustomerGroup_Name] as CustomerGroup
      ,[Hours]
     FROM [MDS].[mdm].[WorkforceResources2]
*/
GO
/****** Object:  Table [Dim].[CallResponseSLA]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[CallResponseSLA](
	[Code] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[ServiceWindow] [nvarchar](50) NULL,
	[DayOfWeek] [smallint] NULL,
	[SLAStartTime] [time](0) NULL,
	[SLAEndTime] [time](0) NULL,
	[CallResponseTimeValue] [decimal](9, 2) NULL,
	[CallResponseTimeRate] [decimal](9, 2) NULL,
	[CallDurationValue] [decimal](9, 2) NULL,
	[CallDurationRate] [decimal](9, 2) NULL,
 CONSTRAINT [PK_CallResponseSLA] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[ColourSchema]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[ColourSchema](
	[Code] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[Omschrijving] [nvarchar](100) NULL,
	[Inc_Aangemeld1] [nvarchar](100) NULL,
	[Inc_Aangemeld2] [nvarchar](100) NULL,
	[Inc_Aangemeld3] [nvarchar](100) NULL,
	[Inc_Aangemeld4] [nvarchar](100) NULL,
	[Inc_Afgemeld1] [nvarchar](100) NULL,
	[Inc_Afgemeld2] [nvarchar](100) NULL,
	[Inc_Afgemeld3] [nvarchar](100) NULL,
	[Inc_Afgemeld4] [nvarchar](100) NULL,
	[Inc_Openstaand1] [nvarchar](100) NULL,
	[Inc_Openstaand2] [nvarchar](100) NULL,
	[Inc_Openstaand3] [nvarchar](100) NULL,
	[Inc_Openstaand4] [nvarchar](100) NULL,
	[Inc_Gereed1] [nvarchar](100) NULL,
	[Inc_workload] [nvarchar](100) NULL,
	[Cha_Aangemeld1] [nvarchar](100) NULL,
	[Cha_Aangemeld2] [nvarchar](100) NULL,
	[Cha_Aangemeld3] [nvarchar](100) NULL,
	[Cha_Aangemeld4] [nvarchar](100) NULL,
	[Cha_Afgemeld1] [nvarchar](100) NULL,
	[Cha_Afgemeld2] [nvarchar](100) NULL,
	[Cha_Afgemeld3] [nvarchar](100) NULL,
	[Cha_Afgemeld4] [nvarchar](100) NULL,
	[Cha_Openstaand1] [nvarchar](100) NULL,
	[Cha_Openstaand2] [nvarchar](100) NULL,
	[Cha_Openstaand3] [nvarchar](100) NULL,
	[Cha_Openstaand4] [nvarchar](100) NULL,
	[Cha_Gereed1] [nvarchar](100) NULL,
	[Cha_workload] [nvarchar](100) NULL,
	[Line_target] [nvarchar](100) NULL,
	[Line_mean] [nvarchar](100) NULL,
	[DataLabel] [nvarchar](100) NULL,
	[DataLabelPerc] [nvarchar](100) NULL,
	[Call_Opgenomen] [nvarchar](100) NULL,
	[Call_Opgenomen1] [nvarchar](100) NULL,
	[Call_Opgenomen2] [nvarchar](100) NULL,
	[Call_Opgenomen3] [nvarchar](100) NULL,
	[Call_Opgenomen4] [nvarchar](100) NULL,
	[Call_Nietopgenomen] [nvarchar](100) NULL,
	[Call_workload] [nvarchar](100) NULL,
 CONSTRAINT [PK_ColourSchema] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[Languages]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Languages](
	[LanguagesKey] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Language] [nvarchar](100) NULL,
	[Locale] [nvarchar](100) NULL,
	[Code] [int] NULL,
	[MainLanguage_Code] [int] NULL,
 CONSTRAINT [PK_Languages] PRIMARY KEY CLUSTERED 
(
	[LanguagesKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[NiceReply]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[NiceReply](
	[Reply_ID] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[CreationDate] [date] NULL,
	[CreationTime] [time](0) NULL,
	[TicketLink] [varchar](512) NULL,
	[TicketType] [varchar](20) NULL,
	[TicketID] [uniqueidentifier] NULL,
	[IPAddress] [varchar](20) NULL,
	[Score] [int] NULL,
	[Comment] [nvarchar](max) NULL,
 CONSTRAINT [PK_NiceReply] PRIMARY KEY CLUSTERED 
(
	[Reply_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [Dim].[Object]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Object](
	[ObjectKey] [int] NOT NULL,
	[CallerKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[ChangeDate] [date] NULL,
	[ChangeTime] [time](0) NULL,
	[ObjectID] [nvarchar](255) NULL,
	[Class] [nvarchar](255) NULL,
	[ObjectType] [nvarchar](255) NULL,
	[Model] [nvarchar](255) NULL,
	[PurchasePrice] [money] NULL,
	[PurchaseDate] [date] NULL,
	[PurchaseTime] [time](0) NULL,
	[Budgetholder] [nvarchar](255) NULL,
	[Supplier] [nvarchar](255) NULL,
	[SerialNumber] [nvarchar](255) NULL,
	[Contact] [nvarchar](255) NULL,
	[Attention] [nvarchar](255) NULL,
	[Configuration] [nvarchar](255) NULL,
	[User] [nvarchar](255) NULL,
	[Group] [nvarchar](255) NULL,
	[Hostname] [nvarchar](255) NULL,
	[IPAddress] [nvarchar](255) NULL,
	[LeaseStartDate] [date] NULL,
	[LeaseStartTime] [time](0) NULL,
	[LeaseContractNumber] [nvarchar](255) NULL,
	[LeaseEndDate] [date] NULL,
	[LeaseEndTime] [time](0) NULL,
	[LeasePeriod] [int] NULL,
	[LeasePrice] [money] NULL,
	[LicentieType] [nvarchar](255) NULL,
	[Comments] [nvarchar](255) NULL,
	[OrderNumber] [nvarchar](255) NULL,
	[Person] [nvarchar](255) NULL,
	[Staffgroup] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[ResidualValue] [money] NULL,
	[Room] [nvarchar](255) NULL,
	[Specification] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Branch] [nvarchar](255) NULL,
 CONSTRAINT [PK_Object] PRIMARY KEY CLUSTERED 
(
	[ObjectKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[OperatorGroup]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[OperatorGroup](
	[OperatorGroupKey] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[OperatorGroupID] [uniqueidentifier] NULL,
	[OperatorGroup] [nvarchar](255) NULL,
	[OperatorGroupSTD] [nvarchar](100) NULL,
 CONSTRAINT [PK_OperatorGroup] PRIMARY KEY CLUSTERED 
(
	[OperatorGroupKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[ReportBins]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[ReportBins](
	[Code] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[ChangeTrackingMask] [int] NULL,
	[ReportIncAgeBinLow] [int] NULL,
	[ReportIncAgeBinMid] [int] NULL,
	[ReportIncAgeBinHigh] [int] NULL,
	[ReportIncDurationBinLow] [int] NULL,
	[ReportIncDurationBinMid] [int] NULL,
	[ReportIncDurationBinHigh] [int] NULL,
	[ReportIncSLVerstoringen] [int] NULL,
	[ReportIncSLAanvragenVragen] [int] NULL,
	[ReportIncSLVerstoringBinLow] [int] NULL,
	[ReportIncSLVerstoringBinMid] [int] NULL,
	[ReportIncSLVerstoringBinHigh] [int] NULL,
	[ReportIncSLAanvragenVragenBinLow] [int] NULL,
	[ReportIncSLAanvragenVragenBinMid] [int] NULL,
	[ReportIncSLAanvragenVragenBinHigh] [int] NULL,
 CONSTRAINT [PK_ReportBins] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[ReportInfo]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[ReportInfo](
	[Code] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[ReportName] [nvarchar](100) NULL,
	[LandingPage] [nvarchar](4000) NULL,
	[PDF] [nvarchar](4000) NULL,
	[Word] [nvarchar](4000) NULL,
	[Logo] [nvarchar](100) NULL,
	[EnableIncidents] [tinyint] NULL,
	[EnableChanges] [tinyint] NULL,
	[EnableCalls] [tinyint] NULL,
 CONSTRAINT [PK_ReportInfo] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[ReportLabels]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[ReportLabels](
	[LanguageCode] [int] NOT NULL,
	[Language] [nvarchar](100) NOT NULL,
	[Locale] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Code] [int] NOT NULL,
	[Translation] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_ReportLabels] PRIMARY KEY CLUSTERED 
(
	[LanguageCode] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[Change]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Change](
	[Change_Id] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[AuditDWKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[CallerKey] [int] NOT NULL,
	[OperatorGroupKey] [int] NOT NULL,
	[Category] [nvarchar](255) NULL,
	[CardChangedBy] [nvarchar](255) NULL,
	[ChangeDate] [date] NULL,
	[ChangeTime] [time](0) NULL,
	[ClosureDateSimpleChange] [date] NULL,
	[ClosureTimeSimpleChange] [time](0) NULL,
	[Closed] [bit] NULL,
	[CardCreatedBy] [nvarchar](255) NULL,
	[CustomerName] [nvarchar](255) NULL,
	[ExternalNumber] [nvarchar](255) NULL,
	[Impact] [nvarchar](255) NULL,
	[ChangeNumber] [nvarchar](255) NULL,
	[ObjectID] [nvarchar](255) NULL,
	[Priority] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Subcategory] [nvarchar](255) NULL,
	[AuthorizationDate] [date] NULL,
	[AuthorizationTime] [time](0) NULL,
	[CancelDateExtChange] [date] NULL,
	[CancelTimeExtChange] [time](0) NULL,
	[CancelledByManager] [nvarchar](255) NULL,
	[CancelledByOperator] [nvarchar](255) NULL,
	[ChangeType] [nvarchar](255) NULL,
	[Coordinator] [nvarchar](255) NULL,
	[CreationDate] [date] NULL,
	[CreationTime] [time](0) NULL,
	[CurrentPhase] [nvarchar](255) NULL,
	[CurrentPhaseSTD] [nvarchar](100) NULL,
	[DateCalcTypeEvaluation] [nvarchar](255) NULL,
	[DateCalcTypeProgress] [nvarchar](255) NULL,
	[DateCalcTypeRequestChange] [nvarchar](255) NULL,
	[DescriptionBrief] [nvarchar](255) NULL,
	[EndDateExtChange] [date] NULL,
	[EndTimeExtChange] [time](0) NULL,
	[Evaluation] [bit] NULL,
	[ImplDateExtChange] [date] NULL,
	[ImplTimeExtChange] [time](0) NULL,
	[ImplDateSimpleChange] [date] NULL,
	[ImplTimeSimpleChange] [time](0) NULL,
	[Implemented] [bit] NULL,
	[MajorIncidentId] [nvarchar](255) NULL,
	[NoGoDateExtChange] [date] NULL,
	[NoGoTimeExtChange] [time](0) NULL,
	[OperatorEvaluationExtChange] [nvarchar](255) NULL,
	[OperatorProgressExtChange] [nvarchar](255) NULL,
	[OperatorRequestChange] [nvarchar](255) NULL,
	[OperatorSimpleChange] [nvarchar](255) NULL,
	[OriginalIncident] [nvarchar](255) NULL,
	[PlannedAuthDateRequestChange] [date] NULL,
	[PlannedAuthTimeRequestChange] [time](0) NULL,
	[PlannedFinalDate] [date] NULL,
	[PlannedFinalTime] [time](0) NULL,
	[PlannedImplDate] [date] NULL,
	[PlannedImplTime] [time](0) NULL,
	[PlannedStartDateSimpleChange] [date] NULL,
	[PlannedStartTimeSimpleChange] [time](0) NULL,
	[ProcessingStatus] [nvarchar](255) NULL,
	[Rejected] [bit] NULL,
	[RejectionDate] [date] NULL,
	[RejectionTime] [time](0) NULL,
	[RequestDate] [date] NULL,
	[RequestTime] [time](0) NULL,
	[StartDateSimpleChange] [date] NULL,
	[StartTimeSimpleChange] [time](0) NULL,
	[Started] [bit] NULL,
	[SubmissionDateRequestChange] [date] NULL,
	[SubmissionTimeRequestChange] [time](0) NULL,
	[Template] [nvarchar](255) NULL,
	[TimeSpent] [bigint] NULL,
	[Type] [nvarchar](255) NULL,
	[TypeSTD] [nvarchar](100) NULL,
	[Urgency] [bit] NULL,
	[ClosureDate] [date] NULL,
	[ClosureTime] [time](0) NULL,
	[CompletionDate] [date] NULL,
	[CompletionTime] [time](0) NULL,
	[RequestedBy] [nvarchar](32) NULL,
	[FirstTimeRight] [bit] NULL,
 CONSTRAINT [PK_Change] PRIMARY KEY CLUSTERED 
(
	[Change_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[ChangeActivity]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[ChangeActivity](
	[ChangeActivity_Id] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[AuditDWKey] [int] NOT NULL,
	[ChangeKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[OperatorGroupKey] [int] NOT NULL,
	[OperatorKey] [int] NOT NULL,
	[ChangeDate] [date] NULL,
	[ChangeTime] [time](0) NULL,
	[Approved] [bit] NULL,
	[ApprovedDate] [date] NULL,
	[ApprovedTime] [time](0) NULL,
	[BriefDescription] [nvarchar](255) NULL,
	[CurrentPlanTimeTaken] [bigint] NULL,
	[CreationDate] [date] NULL,
	[CreationTime] [time](0) NULL,
	[ActivityNumber] [nvarchar](255) NULL,
	[OriginalPlanTimeTaken] [bigint] NULL,
	[ChangePhase] [int] NULL,
	[PlannedFinalDate] [date] NULL,
	[PlannedFinalTime] [time](0) NULL,
	[PlannedStartDate] [date] NULL,
	[PlannedStartTime] [time](0) NULL,
	[Rejected] [bit] NULL,
	[RejectedDate] [date] NULL,
	[RejectedTime] [time](0) NULL,
	[Resolved] [bit] NULL,
	[ResolvedDate] [date] NULL,
	[ResolvedTime] [time](0) NULL,
	[Skipped] [bit] NULL,
	[SkippedDate] [date] NULL,
	[SkippedTime] [time](0) NULL,
	[Closed] [bit] NULL,
	[ClosureDate] [date] NULL,
	[ClosureTime] [time](0) NULL,
	[Started] [bit] NULL,
	[StartedDate] [date] NULL,
	[StartedTime] [time](0) NULL,
	[TimeTaken] [bigint] NULL,
	[MayStart] [bit] NULL,
	[ChangeBriefDescription] [nvarchar](255) NULL,
	[ActivityTemplate] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[ActivityChange] [nvarchar](255) NULL,
	[Subcategory] [nvarchar](255) NULL,
	[CardCreatedBy] [nvarchar](255) NULL,
	[CardChangedBy] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[ProcessingStatus] [nvarchar](255) NULL,
	[MaxPreviousActivityEndDate] [datetime] NULL,
	[ChangePhaseStartDate] [datetime] NULL,
	[Level] [tinyint] NULL,
	[PlannedStartRank] [int] NULL,
 CONSTRAINT [PK_ChangeActivity] PRIMARY KEY CLUSTERED 
(
	[ChangeActivity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[ChangeActivityWithPrevious]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[ChangeActivityWithPrevious](
	[ChangeActivity_Id] [int] NOT NULL,
	[ChangeKey] [int] NOT NULL,
	[plannedstartdate] [datetime] NULL,
	[plannedfinaldate] [datetime] NULL,
	[PreviousChangeActivity_Id] [int] NULL,
	[PreviousActivityEndDate] [datetime] NULL,
	[ChangePhaseStartDate] [datetime] NULL,
	[briefdescription] [nvarchar](255) NULL,
	[Level] [tinyint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[Incident]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Incident](
	[Incident_Id] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[AuditDWKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[CallerKey] [int] NOT NULL,
	[OperatorGroupKey] [int] NOT NULL,
	[ObjectKey] [int] NOT NULL,
	[DurationActual] [bigint] NULL,
	[DurationAdjusted] [bigint] NULL,
	[Category] [nvarchar](255) NULL,
	[ConfigurationID] [nvarchar](255) NULL,
	[CardChangedBy] [nvarchar](255) NULL,
	[ChangeDate] [date] NULL,
	[ChangeTime] [time](0) NULL,
	[ClosureDate] [date] NULL,
	[ClosureTime] [time](0) NULL,
	[Closed] [bit] NULL,
	[CompletionDate] [date] NULL,
	[CompletionTime] [time](0) NULL,
	[Completed] [bit] NULL,
	[CardCreatedBy] [nvarchar](255) NULL,
	[CreationDate] [date] NULL,
	[CreationTime] [time](0) NULL,
	[CustomerName] [nvarchar](255) NULL,
	[CustomerAbbreviation] [nvarchar](100) NULL,
	[IncidentDescription] [nvarchar](255) NULL,
	[DurationOnHold] [bigint] NULL,
	[Duration] [nvarchar](255) NULL,
	[EntryType] [nvarchar](255) NULL,
	[EntryTypeSTD] [nvarchar](100) NULL,
	[ExternalNumber] [nvarchar](255) NULL,
	[Onhold] [bit] NULL,
	[IsMajorIncident] [bit] NULL,
	[Impact] [nvarchar](255) NULL,
	[IncidentDate] [date] NULL,
	[IncidentTime] [time](0) NULL,
	[Line] [nvarchar](255) NULL,
	[MajorIncident] [nvarchar](255) NULL,
	[IncidentNumber] [nvarchar](255) NULL,
	[OnHoldDate] [date] NULL,
	[OnHoldTime] [time](0) NULL,
	[ObjectID] [nvarchar](255) NULL,
	[Priority] [nvarchar](255) NULL,
	[PrioritySTD] [nvarchar](100) NULL,
	[Sla] [nvarchar](255) NULL,
	[SlaContract] [nvarchar](255) NULL,
	[StandardSolution] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[StatusSTD] [nvarchar](100) NULL,
	[SlaTargetDate] [date] NULL,
	[SlaTargetTime] [time](0) NULL,
	[Subcategory] [nvarchar](255) NULL,
	[Supplier] [nvarchar](255) NULL,
	[ServiceWindow] [nvarchar](255) NULL,
	[TargetDate] [date] NULL,
	[TargetTime] [time](0) NULL,
	[TimeSpentFirstLine] [bigint] NULL,
	[TotalTime] [bigint] NULL,
	[TimeSpentSecondLine] [bigint] NULL,
	[IncidentType] [nvarchar](255) NULL,
	[IncidentTypeSTD] [nvarchar](100) NULL,
	[SlaAchieved] [nvarchar](255) NULL,
	[DurationAdjustedActualCombi] [bigint] NULL,
	[SlaAchievedFlag] [int] NULL,
	[Bounced] [tinyint] NULL,
	[HandledByOGD] [bit] NULL,
 CONSTRAINT [PK_Incident] PRIMARY KEY CLUSTERED 
(
	[Incident_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[ProbleemVermoeden]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[ProbleemVermoeden](
	[ProbleemVermoeden_ID] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[AuditDWKey] [int] NOT NULL,
	[IncidentKey] [int] NOT NULL,
	[CreationDate] [date] NULL,
	[CreationTime] [time](0) NULL,
	[OperatorName] [nvarchar](255) NULL,
	[Memo] [nvarchar](max) NULL,
 CONSTRAINT [PK_ProbleemVermoeden] PRIMARY KEY CLUSTERED 
(
	[ProbleemVermoeden_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [Fact].[Problem]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Problem](
	[Problem_Id] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[AuditDWKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[OperatorGroupKey] [int] NOT NULL,
	[OperatorKey] [int] NOT NULL,
	[ChangeDate] [date] NULL,
	[ChangeTime] [time](0) NULL,
	[KnownErrorDate] [date] NULL,
	[KnownErrorTime] [time](0) NULL,
	[ProblemDate] [date] NULL,
	[ProblemTime] [time](0) NULL,
	[CardCreatedBy] [nvarchar](255) NULL,
	[Closed] [bit] NULL,
	[ClosedKownError] [bit] NULL,
	[ClosedProblem] [bit] NULL,
	[EstimatedTimeSpent] [bigint] NULL,
	[EstimatedCosts] [money] NULL,
	[TimeSpent] [bigint] NULL,
	[TimespentKnownError] [bigint] NULL,
	[TimespentProblem] [bigint] NULL,
	[CategoryKnownError] [nvarchar](255) NULL,
	[CategoryProblem] [nvarchar](255) NULL,
	[CreationDate] [date] NULL,
	[CreationTime] [time](0) NULL,
	[ClosureDate] [date] NULL,
	[ClosureTime] [time](0) NULL,
	[ClosureDateKnownError] [date] NULL,
	[ClosureTimeKnownError] [time](0) NULL,
	[ClosureDateProblem] [date] NULL,
	[ClosureTimeProblem] [time](0) NULL,
	[CompletionDate] [date] NULL,
	[CompletionTime] [time](0) NULL,
	[CompletionDateKnownError] [date] NULL,
	[CompletionTimeKnownError] [time](0) NULL,
	[CompletionDateProblem] [date] NULL,
	[CompletionTimeProblem] [time](0) NULL,
	[DurationKnownError] [nvarchar](255) NULL,
	[DurationProblem] [nvarchar](255) NULL,
	[ActualTimeSpent] [bigint] NULL,
	[DurationActual] [bigint] NULL,
	[DurationActualKnownError] [bigint] NULL,
	[DurationActualProblem] [bigint] NULL,
	[ActualCosts] [money] NULL,
	[Completed] [bit] NULL,
	[CompletedKnownError] [bit] NULL,
	[CompletedProblem] [bit] NULL,
	[ImpactKnownError] [nvarchar](255) NULL,
	[Impact] [nvarchar](255) NULL,
	[Type] [int] NULL,
	[KnownErrorDescription] [nvarchar](255) NULL,
	[ProblemDescription] [nvarchar](255) NULL,
	[Manager] [nvarchar](255) NULL,
	[RemainingCosts] [money] NULL,
	[CostsKnownError] [money] NULL,
	[Costs] [money] NULL,
	[CostsProblem] [money] NULL,
	[ProblemCause] [nvarchar](255) NULL,
	[Priority] [nvarchar](255) NULL,
	[Problemnumber] [nvarchar](255) NULL,
	[ReasonArchiving] [nvarchar](255) NULL,
	[TimeRemaining] [bigint] NULL,
	[ProblemType] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[StatusProcessFeedback] [nvarchar](255) NULL,
	[TargetDateKnownError] [date] NULL,
	[TargetTimeKnownError] [time](0) NULL,
	[TargetDate] [date] NULL,
	[TargetTime] [time](0) NULL,
	[SubcategoryKnownError] [nvarchar](255) NULL,
	[SubcategoryProblem] [nvarchar](255) NULL,
	[Urgency] [nvarchar](255) NULL,
	[CardChangedBy] [nvarchar](255) NULL,
	[IncidentsCnt] [int] NULL,
	[IncidentsFirstReportedDate] [date] NULL,
	[IncidentsFirstReportedTime] [time](0) NULL,
	[IncidentsLastReportedDate] [date] NULL,
	[IncidentsLastReportedTime] [time](0) NULL,
	[Incidents] [nvarchar](4000) NULL,
	[CausedByChangesCnt] [int] NULL,
	[CausedByChangesFirstExecutedDate] [date] NULL,
	[CausedByChangesFirstExecutedTime] [time](0) NULL,
	[CausedByChangesLastExecutedDate] [date] NULL,
	[CausedByChangesLastExecutedTime] [time](0) NULL,
	[CausedByChanges] [nvarchar](1024) NULL,
	[FixedByChangesCnt] [int] NULL,
	[FixedByChangesFirstExecutedDate] [date] NULL,
	[FixedByChangesFirstExecutedTime] [time](0) NULL,
	[FixedByChangesLastExecutedDate] [date] NULL,
	[FixedByChangesLastExecutedTime] [time](0) NULL,
	[FixedByChanges] [nvarchar](1024) NULL,
	[ObjectsImpactedCnt] [int] NULL,
	[ObjectsImpacted] [nvarchar](1024) NULL,
 CONSTRAINT [PK_Problem] PRIMARY KEY CLUSTERED 
(
	[Problem_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[ProcesFeedback]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[ProcesFeedback](
	[ProcesFeedback_ID] [int] NOT NULL,
	[SourceDatabaseKey] [int] NOT NULL,
	[AuditDWKey] [int] NOT NULL,
	[IncidentKey] [int] NOT NULL,
	[ChangeKey] [int] NOT NULL,
	[CreationDate] [date] NULL,
	[CreationTime] [time](0) NULL,
	[OperatorName] [nvarchar](255) NULL,
	[Memo] [nvarchar](max) NULL,
 CONSTRAINT [PK_ProcesFeedback] PRIMARY KEY CLUSTERED 
(
	[ProcesFeedback_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [Fact].[SupportPerHalfHour]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[SupportPerHalfHour](
	[SupportWindowKey] [tinyint] NOT NULL,
	[DayOfWeek] [tinyint] NOT NULL,
	[half_hour_of_day] [tinyint] NOT NULL,
	[Support] [bit] NULL,
 CONSTRAINT [PK_SupportPerHalfHour] PRIMARY KEY CLUSTERED 
(
	[SupportWindowKey] ASC,
	[DayOfWeek] ASC,
	[half_hour_of_day] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[SupportWindowPerHalfHour]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[SupportWindowPerHalfHour](
	[SupportWindowID] [smallint] NOT NULL,
	[Datetime] [datetime] NOT NULL,
	[TimeStamp] [int] NULL,
	[half_hour_of_day] [int] NOT NULL,
	[support] [tinyint] NULL,
	[SupportedRN] [int] NULL,
	[totalRN] [bigint] NULL,
 CONSTRAINT [PK_SupportWindowPerHalfHour] PRIMARY KEY CLUSTERED 
(
	[SupportWindowID] ASC,
	[Datetime] ASC,
	[half_hour_of_day] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [log].[LastLoad]    Script Date: 5/3/2017 10:33:43 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[LastLoad](
	[LoadDate] [datetime2](0) NULL
) ON [PRIMARY]

GO
ALTER TABLE [Dim].[Date] ADD  DEFAULT ((0)) FOR [DWWorkDayNumber]
GO
ALTER TABLE [log].[LastLoad] ADD  DEFAULT (sysdatetime()) FOR [LoadDate]
GO
ALTER TABLE [Dim].[Object]  WITH CHECK ADD  CONSTRAINT [FK_Object_CallerKey] FOREIGN KEY([CallerKey])
REFERENCES [Dim].[Caller] ([CallerKey])
GO
ALTER TABLE [Dim].[Object] CHECK CONSTRAINT [FK_Object_CallerKey]
GO
ALTER TABLE [Dim].[Object]  WITH CHECK ADD  CONSTRAINT [FK_Object_CustomerKey] FOREIGN KEY([CustomerKey])
REFERENCES [Dim].[Customer] ([CustomerKey])
GO
ALTER TABLE [Dim].[Object] CHECK CONSTRAINT [FK_Object_CustomerKey]
GO
ALTER TABLE [Fact].[Call]  WITH CHECK ADD  CONSTRAINT [FK_Call_CustomerKey] FOREIGN KEY([CustomerKey])
REFERENCES [Dim].[Customer] ([CustomerKey])
GO
ALTER TABLE [Fact].[Call] CHECK CONSTRAINT [FK_Call_CustomerKey]
GO
ALTER TABLE [Fact].[Change]  WITH CHECK ADD  CONSTRAINT [FK_Change_CallerKey] FOREIGN KEY([CallerKey])
REFERENCES [Dim].[Caller] ([CallerKey])
GO
ALTER TABLE [Fact].[Change] CHECK CONSTRAINT [FK_Change_CallerKey]
GO
ALTER TABLE [Fact].[Change]  WITH CHECK ADD  CONSTRAINT [FK_Change_CustomerKey] FOREIGN KEY([CustomerKey])
REFERENCES [Dim].[Customer] ([CustomerKey])
GO
ALTER TABLE [Fact].[Change] CHECK CONSTRAINT [FK_Change_CustomerKey]
GO
ALTER TABLE [Fact].[Change]  WITH CHECK ADD  CONSTRAINT [FK_Change_OperatorGroupKey] FOREIGN KEY([OperatorGroupKey])
REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
GO
ALTER TABLE [Fact].[Change] CHECK CONSTRAINT [FK_Change_OperatorGroupKey]
GO
ALTER TABLE [Fact].[ChangeActivity]  WITH CHECK ADD  CONSTRAINT [FK_ChangeActivity_ChangeKey] FOREIGN KEY([ChangeKey])
REFERENCES [Fact].[Change] ([Change_Id])
GO
ALTER TABLE [Fact].[ChangeActivity] CHECK CONSTRAINT [FK_ChangeActivity_ChangeKey]
GO
ALTER TABLE [Fact].[ChangeActivity]  WITH CHECK ADD  CONSTRAINT [FK_ChangeActivity_CustomerKey] FOREIGN KEY([CustomerKey])
REFERENCES [Dim].[Customer] ([CustomerKey])
GO
ALTER TABLE [Fact].[ChangeActivity] CHECK CONSTRAINT [FK_ChangeActivity_CustomerKey]
GO
ALTER TABLE [Fact].[ChangeActivity]  WITH CHECK ADD  CONSTRAINT [FK_ChangeActivity_OperatorGroupKey] FOREIGN KEY([OperatorGroupKey])
REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
GO
ALTER TABLE [Fact].[ChangeActivity] CHECK CONSTRAINT [FK_ChangeActivity_OperatorGroupKey]
GO
ALTER TABLE [Fact].[ChangeActivityWithPrevious]  WITH CHECK ADD  CONSTRAINT [FK_ChangeActivityWithPrevious_ChangeActivity_ID] FOREIGN KEY([ChangeActivity_Id])
REFERENCES [Fact].[ChangeActivity] ([ChangeActivity_Id])
GO
ALTER TABLE [Fact].[ChangeActivityWithPrevious] CHECK CONSTRAINT [FK_ChangeActivityWithPrevious_ChangeActivity_ID]
GO
ALTER TABLE [Fact].[ChangeActivityWithPrevious]  WITH CHECK ADD  CONSTRAINT [FK_ChangeActivityWithPrevious_ChangeKey] FOREIGN KEY([ChangeKey])
REFERENCES [Fact].[Change] ([Change_Id])
GO
ALTER TABLE [Fact].[ChangeActivityWithPrevious] CHECK CONSTRAINT [FK_ChangeActivityWithPrevious_ChangeKey]
GO
ALTER TABLE [Fact].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_CallerKey] FOREIGN KEY([CallerKey])
REFERENCES [Dim].[Caller] ([CallerKey])
GO
ALTER TABLE [Fact].[Incident] CHECK CONSTRAINT [FK_Incident_CallerKey]
GO
ALTER TABLE [Fact].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_CustomerKey] FOREIGN KEY([CustomerKey])
REFERENCES [Dim].[Customer] ([CustomerKey])
GO
ALTER TABLE [Fact].[Incident] CHECK CONSTRAINT [FK_Incident_CustomerKey]
GO
ALTER TABLE [Fact].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_ObjectKey] FOREIGN KEY([ObjectKey])
REFERENCES [Dim].[Object] ([ObjectKey])
GO
ALTER TABLE [Fact].[Incident] CHECK CONSTRAINT [FK_Incident_ObjectKey]
GO
ALTER TABLE [Fact].[Incident]  WITH CHECK ADD  CONSTRAINT [FK_Incident_OperatorGroupKey] FOREIGN KEY([OperatorGroupKey])
REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
GO
ALTER TABLE [Fact].[Incident] CHECK CONSTRAINT [FK_Incident_OperatorGroupKey]
GO
ALTER TABLE [Fact].[ProbleemVermoeden]  WITH CHECK ADD  CONSTRAINT [FK_ProbleemVermoeden_IncidentKey] FOREIGN KEY([IncidentKey])
REFERENCES [Fact].[Incident] ([Incident_Id])
GO
ALTER TABLE [Fact].[ProbleemVermoeden] CHECK CONSTRAINT [FK_ProbleemVermoeden_IncidentKey]
GO
ALTER TABLE [Fact].[Problem]  WITH CHECK ADD  CONSTRAINT [FK_Problem_CustomerKey] FOREIGN KEY([CustomerKey])
REFERENCES [Dim].[Customer] ([CustomerKey])
GO
ALTER TABLE [Fact].[Problem] CHECK CONSTRAINT [FK_Problem_CustomerKey]
GO
ALTER TABLE [Fact].[Problem]  WITH CHECK ADD  CONSTRAINT [FK_Problem_OperatorGroupKey] FOREIGN KEY([OperatorGroupKey])
REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
GO
ALTER TABLE [Fact].[Problem] CHECK CONSTRAINT [FK_Problem_OperatorGroupKey]
GO
ALTER TABLE [Fact].[Problem]  WITH CHECK ADD  CONSTRAINT [FK_Problem_OperatorKey] FOREIGN KEY([OperatorKey])
REFERENCES [Dim].[Caller] ([CallerKey])
GO
ALTER TABLE [Fact].[Problem] CHECK CONSTRAINT [FK_Problem_OperatorKey]
GO
ALTER TABLE [Fact].[ProcesFeedback]  WITH CHECK ADD  CONSTRAINT [FK_ProcesFeedback_ChangeKey] FOREIGN KEY([ChangeKey])
REFERENCES [Fact].[Change] ([Change_Id])
GO
ALTER TABLE [Fact].[ProcesFeedback] CHECK CONSTRAINT [FK_ProcesFeedback_ChangeKey]
GO
ALTER TABLE [Fact].[ProcesFeedback]  WITH CHECK ADD  CONSTRAINT [FK_ProcesFeedback_IncidentKey] FOREIGN KEY([IncidentKey])
REFERENCES [Fact].[Incident] ([Incident_Id])
GO
ALTER TABLE [Fact].[ProcesFeedback] CHECK CONSTRAINT [FK_ProcesFeedback_IncidentKey]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AgentName_Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AgentName_Email'
GO

/****** Object:  DatabaseRole [BBHDashboard]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE ROLE [BBHDashboard]
GO
/****** Object:  DatabaseRole [BI-Basis]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE ROLE [BI-Basis]
GO
/****** Object:  DatabaseRole [Finance]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE ROLE [Finance]
GO
/****** Object:  DatabaseRole [HumanResources]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE ROLE [HumanResources]
GO
/****** Object:  DatabaseRole [Operations]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE ROLE [Operations]
GO
/****** Object:  Schema [Dim]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE SCHEMA [Dim]
GO
/****** Object:  Schema [Fact]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE SCHEMA [Fact]
GO
/****** Object:  Schema [log]    Script Date: 5/3/2017 10:32:59 AM ******/
CREATE SCHEMA [log]
GO
/****** Object:  Table [Dim].[AccountManager]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[AccountManager](
	[AccountManagerKey] [int] IDENTITY(30000000,1) NOT FOR REPLICATION NOT NULL,
	[unid] [uniqueidentifier] NULL,
	[AccountManagerName] [nvarchar](100) NULL,
 CONSTRAINT [PK_AccountManager_AccountManagerKey] PRIMARY KEY CLUSTERED 
(
	[AccountManagerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[Contactperson]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Contactperson](
	[CustomerKey] [int] NOT NULL,
	[Contactperson] [nvarchar](100) NULL,
	[Jobtitle] [nvarchar](50) NULL,
	[Telephone_1] [nvarchar](25) NULL,
	[Telephone_2] [nvarchar](25) NULL,
	[Mail] [nvarchar](75) NULL,
	[Department] [nvarchar](60) NULL,
	[Responsibility] [nvarchar](100) NULL,
	[Gender] [nvarchar](10) NULL,
	[LinkedIN] [nvarchar](250) NULL,
	[#] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[Employee]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Employee](
	[EmployeeKey] [int] IDENTITY(20000000,1) NOT FOR REPLICATION NOT NULL,
	[unid] [uniqueidentifier] NULL,
	[EmployeeNumber] [nvarchar](9) NULL,
	[LastName] [nvarchar](30) NULL,
	[GivenName] [nvarchar](20) NULL,
	[Prefixes] [nvarchar](10) NULL,
	[LastNameFirst] [nvarchar](120) NULL,
	[FullName] [nvarchar](120) NULL,
	[BirthYear] [int] NULL,
	[ContractStartDate] [date] NULL,
	[ContractEndDate] [date] NULL,
	[ContractType] [nvarchar](60) NULL,
	[ActiveContract] [bit] NOT NULL,
	[Street] [nvarchar](50) NULL,
	[HouseNumber] [nvarchar](20) NULL,
	[City] [nvarchar](30) NULL,
	[PostalCode] [nvarchar](15) NULL,
 CONSTRAINT [PK_Employee_EmployeeKey] PRIMARY KEY CLUSTERED 
(
	[EmployeeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[HourType]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[HourType](
	[HourTypeKey] [int] IDENTITY(50000000,1) NOT FOR REPLICATION NOT NULL,
	[Percentage] [decimal](19, 4) NULL,
	[Billable] [bit] NULL,
	[RateName] [nvarchar](30) NULL,
 CONSTRAINT [PK_HourType] PRIMARY KEY CLUSTERED 
(
	[HourTypeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[Project]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Project](
	[ProjectKey] [int] IDENTITY(40000000,1) NOT FOR REPLICATION NOT NULL,
	[unid] [uniqueidentifier] NULL,
	[ProjectNumber] [nvarchar](20) NULL,
	[ProjectName] [nvarchar](70) NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[ProductGroup] [nvarchar](30) NOT NULL,
	[Product] [nvarchar](30) NOT NULL,
	[ProjectGroupNumber] [nvarchar](30) NULL,
	[ProjectGroupName] [nvarchar](70) NULL,
	[ProjectStatus] [int] NULL,
	[ProjectStartDate] [date] NULL,
	[ProjectEndDate] [date] NULL,
	[ProjectCreationDate] [date] NULL,
	[ProjectChangeDate] [date] NULL,
	[ProjectArchiveDate] [date] NULL,
	[Office] [nvarchar](40) NULL,
 CONSTRAINT [PK_Project_ProjectKey] PRIMARY KEY CLUSTERED 
(
	[ProjectKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Dim].[Service]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Dim].[Service](
	[ServiceKey] [int] IDENTITY(60000000,1) NOT FOR REPLICATION NOT NULL,
	[ProductNomination] [nvarchar](30) NULL,
 CONSTRAINT [PK_Service] PRIMARY KEY CLUSTERED 
(
	[ServiceKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[Hour]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Hour](
	[unid] [uniqueidentifier] NULL,
	[ProjectKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[HourTypeKey] [int] NOT NULL,
	[ServiceKey] [int] NOT NULL,
	[Hours] [decimal](19, 6) NULL,
	[Day] [date] NULL,
	[ChangeDate] [date] NULL,
	[Rate] [decimal](19, 4) NULL,
	[ProductNomination] [nvarchar](30) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [Fact].[Planning]    Script Date: 5/3/2017 10:32:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Fact].[Planning](
	[ProjectKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[EmployeeKey] [int] NOT NULL,
	[RequestNumber] [nvarchar](20) NULL,
	[PlanningStartDate] [date] NULL,
	[PlanningEndDate] [date] NULL,
	[PlanningDate] [date] NULL,
	[WorkloadWeekly] [decimal](19, 4) NULL,
	[WorkloadDaily] [decimal](19, 4) NULL,
	[Rate] [decimal](19, 4) NULL,
	[PlannedTurnover] [decimal](19, 4) NULL,
	[ChangeDate] [date] NULL,
	[Internal] [bit] NULL
) ON [PRIMARY]

GO