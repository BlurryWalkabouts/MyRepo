CREATE PROCEDURE [etl].[LoadFactOperationalActivity]
AS
BEGIN

/***************************************************************************************************
* Fact.OperationalAcitivity
****************************************************************************************************
*
***************************************************************************************************/

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM [$(OGDW)].Fact.OperationalActivity
DBCC CHECKIDENT ('[$(OGDW)].Fact.OperationalActivity', RESEED, 0)

DROP TABLE IF EXISTS #Dates
DROP TABLE IF EXISTS #Herhaling
DROP TABLE IF EXISTS #Projection

/*
SELECT * FROM #Dates
SELECT * FROM #Herhaling
SELECT * FROM #Projection
*/

-- Temp tabel #Dates om twee extra kolommen aan Dim.Date toe te voegen. Deze moeten wellicht geconsolideerd worden in Dim.Date
SELECT
	[Date]
	, [DayOfWeek]
	, DayInMonth
	, WeekdayOfMonth = ROW_NUMBER() OVER (PARTITION BY CalendarYear, MonthOfYear, [DayOfWeek] ORDER BY [Date] ASC)
	, LastOfMonth = CASE WHEN ROW_NUMBER() OVER (PARTITION BY CalendarYear, MonthOfYear, [DayOfWeek] ORDER BY [Date] DESC) = 1 THEN 1 ELSE 0 END
INTO
	#Dates
FROM
	[$(OGDW)].Dim.[Date]
WHERE 1=1
--	AND CalendarYear IN (2017, 2018);

-- Temp tabel #Herhaling gemaakt om latere joins te versimpelen
IF OBJECT_ID('tempdb..#Herhaling') IS NULL
SELECT
	SourceDatabaseKey = r.SourceDatabaseKey
	, planningid = p.unid
	, startdatum = p.startdatum
	, einddatum = p.einddatum
	, ingeplandtotdatum = p.ingeplandtotdatum
	, aantalherhalingen = p.aantalherhalingen
	, periode = h.periode
	, interval = CASE
			WHEN h.periode = 'DAILY' THEN h.daginterval
			WHEN h.periode = 'WEEKLY' THEN h.weekinterval
			WHEN h.periode = 'MONTHLY' THEN h.maandinterval
			WHEN h.periode = 'YEARLY' THEN h.jaarinterval
			ELSE -1
		END
	, weekdag = CASE
			-- Converting ma t/m zo kolommen naar weekdag
			WHEN h.maandag = 1 THEN 1
			WHEN h.dinsdag = 1 THEN 2
			WHEN h.woensdag = 1 THEN 3
			WHEN h.donderdag = 1 THEN 4
			WHEN h.vrijdag = 1 THEN 5
			WHEN h.zaterdag = 1 THEN 6
			WHEN h.zondag = 1 THEN 7
			-- Converting dagvanweek naar weekdag
			-- In TOPdesk begint weekdag te tellen bij Zondag (=1), in DW begint de week op maandag (=2) | Nadeel van deze correctie is dat voor de zondagen het weeknummer
			-- dus eigenlijk 1 hoger zou moeten zijn, kan een probleem zijn zodra zondagen gebruikt gaan worden.
			WHEN h.dagvanweek > 1 THEN h.dagvanweek - 1
			WHEN h.dagvanweek = 1 THEN 7
			ELSE -1
		END
	, h.jaarperiode
	, maandvanjaar = h.maandvanjaar + 1
	, h.maandperiode
	, h.weekvanmaand
	, h.dagvanmaand
INTO
	#Herhaling
FROM
	[$(OGDW_Archive)].TOPdesk.om_reeks r
	INNER JOIN [$(OGDW_Archive)].TOPdesk.herhaling h ON r.planningid = h.planningid AND r.SourceDatabaseKey = h.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.planning p ON h.planningid = p.unid AND h.SourceDatabaseKey = p.SourceDatabaseKey
WHERE 1=1
	AND r.[status] > 0

-- Temp tabel #Projection gemaakt om de voorspellingen te doen
IF OBJECT_ID('tempdb..#Projection') IS NULL
SELECT
	SourceDatabaseKey = h.SourceDatabaseKey
	, planningid = h.planningid
	, startdatum = d.[Date]
	, activiteitnummer = CONCAT('PR', FORMAT(d.[Date],'yyMM','nl-nl'), RIGHT(CONCAT('0000', ROW_NUMBER() OVER (PARTITION BY YEAR(d.[Date]), MONTH(d.[Date]) ORDER BY d.[Date])),4))
INTO
	#Projection
FROM
	#Herhaling h
	INNER JOIN #Dates d ON d.[Date] > h.ingeplandtotdatum AND (d.[Date] <= h.einddatum OR h.einddatum IS NULL)
WHERE 1<>1
	--/* Yearly pattern
	OR
	(1=1
		AND h.periode = 'YEARLY'
		AND DATEDIFF(YEAR,h.startdatum,d.[Date]) % h.interval = 0
		AND h.maandvanjaar = DATEPART(MM,d.[Date])
		AND
		(
			(
				h.maandperiode = 'WEEKOFMONTH'
				AND
				(
					h.weekvanmaand = d.WeekdayOfMonth AND h.weekdag = d.[DayOfWeek] -- indien iets als "tweede woensdag van de maand" is aangegeven
				)
				OR
				(
					h.weekvanmaand = -1 AND d.LastOfMonth = 1 AND h.weekdag = d.[DayOfWeek] -- indien iets als "laatste x van de maand" is aangegeven
				)
			)
			OR
			(
				h.maandperiode = 'DAYOFMONTH' AND h.dagvanmaand = d.DayInMonth -- indien iets als "iedere 12e van de maand" is aangegeven
			)
		)
	) -- End of yearly pattern */

	--/* Monthly pattern
	OR
	(1=1
		AND h.periode = 'MONTHLY'
		AND DATEDIFF(MM,h.startdatum,d.[Date]) % h.interval = 0
		AND
		(
			(
				h.maandperiode = 'WEEKOFMONTH'
				AND
				(
					h.weekvanmaand = d.WeekdayOfMonth AND h.weekdag = d.[DayOfWeek] -- indien iets als "tweede woensdag van de maand" is aangegeven
				)
				OR
				(
					h.weekvanmaand = -1 AND d.LastOfMonth = 1 AND h.weekdag = d.[DayOfWeek] -- indien iets als "laatste x van de maand" is aangegeven
				)
			)
			OR
			(
				h.maandperiode = 'DAYOFMONTH' AND h.dagvanmaand = d.DayInMonth -- indien iets als "iedere 12e van de maand" is aangegeven
			)
		)
	) -- End of monthly pattern */

	--/* Weekly pattern
	OR
	(1=1
		AND h.periode = 'WEEKLY'
		AND DATEDIFF(WK,h.startdatum,d.[Date]) % h.interval = 0
		AND h.weekdag = d.[DayOfWeek]
	) -- End of weekly pattern */

	--/* Daily pattern
	OR
	(1=1
		AND h.periode = 'DAILY'
		AND DATEDIFF(DD,h.startdatum,d.[Date]) % h.interval = 0
	) -- End of daily pattern */

;WITH [Output] AS
(
SELECT
	SourceDatabaseKey = oa.SourceDatabaseKey
	, AuditDWKey = oa.AuditDWKey
	, Projected = 0
	, activiteitnummer = oa.nummer
	, activiteitnaam = oa.naam 
	, [status] = oa.[status]
	, dataanmk = oa.dataanmk
	, datwijzig = oa.datwijzig
	, startdatumgepland = CAST(oa.startdatumgepland AS datetime2(0))
	, einddatumgepland = CAST(oa.einddatumgepland AS datetime2(0))
	, datumafgemeld = CAST(oa.datumafgemeld AS datetime2(0))
	, afgemeld = oa.afgemeld
	, overgeslagen = oa.overgeslagen
	, bestedetijd = oa.bestedetijd
	, reeksnummer = r.nummer
	, schemaid = oa.schemaid
	, operatorgroupid = oa.operatorgroupid
	, behandelaarid = oa.behandelaarid
FROM
	[$(OGDW_Archive)].TOPdesk.om_activiteit oa
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.om_reeks r ON oa.reeksid = r.unid AND oa.SourceDatabaseKey = r.SourceDatabaseKey

UNION

SELECT
	SourceDatabaseKey = r.SourceDatabaseKey
	, AuditDWKey = r.AuditDWKey
	, Projected = 1
	, activiteitnummer = p.activiteitnummer
	, activiteitnaam = r.naam
	, [status] = r.[status]
	, dataanmk = r.dataanmk
	, datwijzig = r.datwijzig
	, startdatumgepland = CAST(p.startdatum AS datetime2(0))
	, einddatumgepland = NULL
	, datumafgemeld = NULL
	, afgemeld = NULL
	, overgeslagen = NULL
	, bestedetijd = NULL
	, reeksnummer = r.nummer
	, schemaid = r.schemaid
	, operatorgroupid = r.standaardoperatorgroupid
	, behandelaarid = r.standaardbehandelaarid
FROM
	[$(OGDW_Archive)].TOPdesk.om_reeks r
	INNER JOIN #Projection p ON r.planningid = p.planningid AND r.SourceDatabaseKey = p.SourceDatabaseKey
WHERE 1=1
	AND r.[status] > 0
)

INSERT INTO
	[$(OGDW)].Fact.OperationalActivity
	(
	SourceDatabaseKey
	, AuditDWKey
	, CustomerKey
	, OperatorGroupKey
	, OperatorKey
	, Projected
	, OperationalSeriesNumber
	, OperationalActivityNumber
	, OperationalActivityName
	, [Status]
	, CreationDate
	, CreationTime
	, ChangeDate
	, ChangeTime
	, PlannedStartDate
	, PlannedStartTime
	, PlannedFinalDate
	, PlannedFinalTime
	, ClosureDate
	, ClosureTime
	, Closed
	, Skipped
	, TimeSpent
	)
SELECT
	SourceDatabaseKey = o.SourceDatabaseKey
	, AuditDWKey = o.AuditDWKey

	-- Voor Multi-klant topdesk in de FileImport staat de Customer in de kolom [CustomerName], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Multi-klant topdesk in de database staat de Customer in [vestiging].[naam], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Single-klant topdesk in de FileImport is de kolom [CustomerName] = NULL en wordt de naam dus opgehaald via SourceDefinition
	-- Voor Single-klant topdesk in de database bevat de kolom [vestiging].[naam] daadwerkelijk de vestiging; halen we de Customer dus op via SourceDefinition
	-- Via onderstaande regel zou altijd een CustomerKey gevonden moeten worden, tenzij er geen vertaling gedefinieerd is
	, CustomerKey = COALESCE(CAST(CASE
			WHEN SD.MultipleCustomers = 0 THEN C1.Code -- Klantnaam via SourceDefinition
			ELSE COALESCE(C2.Code,-1) -- Klantnaam uit CustomerName veld, vertaald via SourceTranslation naar CustomerKey
		END AS int),-1) -- Bij gegevens uit de database moet deze key op een andere manier worden bepaald
	, OperatorGroupKey = COALESCE(og1.OperatorGroupKey,-1)
	, OperatorKey = COALESCE(og2.OperatorGroupKey,-1)

	, Projected = o.Projected
	, OperationalSeriesNumber = o.reeksnummer
	, OperationalActivityNumber = o.activiteitnummer
	, OperationalActivityName = o.activiteitnaam
	, [Status] = o.[status]
	, CreationDate = CAST(o.dataanmk AS date)
	, CreationTime = CAST(o.dataanmk AS time(0))
	, ChangeDate = CAST(o.datwijzig AS date)
	, ChangeTime = CAST(o.datwijzig AS time(0))
	, PlannedStartDate = CAST(o.startdatumgepland AS date)
	, PlannedStartTime = CAST(o.startdatumgepland AS time(0))
	, PlannedFinalDate = CAST(o.einddatumgepland AS date)
	, PlannedFinalTime = CAST(o.einddatumgepland AS time(0))
	, ClosureDate = CAST(o.datumafgemeld AS date)
	, ClosureTime = CAST(o.datumafgemeld AS time(0))
	, Closed = o.afgemeld
	, Skipped = o.overgeslagen
	, TimeSpent = o.bestedetijd
FROM
	[Output] o

	LEFT OUTER JOIN setup.SourceDefinition SD ON o.SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.DimCustomer C1 ON SD.DatabaseLabel = C1.[Name]
	-- De schemanaam (s.naam) wordt in de MKBO-database (40) gebruikt om de klantnaam in op te slaan
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.om_schema s ON o.schemaid = s.unid AND o.SourceDatabaseKey = s.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceTranslation ST ON s.naam = ST.SourceValue AND SD.DatabaseLabel = ST.SourceName
		AND ST.DWColumnName = 'CustomerName' AND TranslatedColumnName = 'CustomerAbbreviation' AND s.SourceDatabaseKey IN (40)
	LEFT OUTER JOIN setup.DimCustomer C2 ON ST.TranslatedValue = C2.[Name]

	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og1 ON o.operatorgroupid = og1.OperatorGroupID AND o.SourceDatabaseKey = og1.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og2 ON o.behandelaarid = og2.OperatorGroupID AND o.SourceDatabaseKey = og2.SourceDatabaseKey

SET @newRowCount += @@ROWCOUNT

DROP TABLE IF EXISTS #Dates
DROP TABLE IF EXISTS #Herhaling
DROP TABLE IF EXISTS #Projection

COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END