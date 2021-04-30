CREATE PROCEDURE [etl].[LoadFactProcesFeedback]
AS
BEGIN

/***************************************************************************************************
* [etl].[LoadFactProcesFeedback]
****************************************************************************************************
* Mogelijk probleem: wat gebeurt er als de memo in een kolom staat die nog niet gestaged wordt?
* Code overlapt erg met LoadProbleemVermoeden
****************************************************************************************************
* 2017-03-10 * WvdS  * Eerste versie
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

DELETE FROM [$(OGDW)].Fact.ProcesFeedback

/*
Omdat de procesfeedback in de brontabellen in verschillende kolommen staan, kan deze niet zomaar 1-op-1
worden overgenomen, maar moet deze middels dynamische sql eerste in een temp tabel worden geladen. In de
tabel etl.CustomColumns staat voor iedere SDK beschreven in welke kolom de data staat.
*/

DROP TABLE IF EXISTS #ProcesFeedback
CREATE TABLE #ProcesFeedback
(
	SourceDatabaseKey int
	, AuditDWKey int
	, IncidentNumber nvarchar(255)
	, ChangeNumber nvarchar(255)
	, Contents nvarchar(max)
)

-- Genereer het INSERT statement voor iedere SDK en iedere brontabel
DECLARE ExecuteBatches CURSOR FOR
(
SELECT SQLString = '
	INSERT INTO
		#Procesfeedback
	SELECT
		SourceDatabaseKey
		, AuditDWKey
		, IncidentNumber = naam
		, ChangeNumber = NULL
		, Contents = ' + COLUMN_NAME + '
	FROM
		[$(OGDW_Archive)].TOPdesk.' + TABLE_NAME + '
	WHERE 1=1
		AND ' + COLUMN_NAME + ' IS NOT NULL
		AND SourceDatabaseKey = ' + CAST(SourceDatabaseKey AS nvarchar(10)) + ''
FROM
	etl.CustomColumns
WHERE 1=1
	AND ColumnDefinition = 'Procesfeedback'
	AND TABLE_NAME = 'incident'
UNION
SELECT SQLString = '
	INSERT INTO
		#Procesfeedback
	SELECT
		SourceDatabaseKey
		, AuditDWKey
		, IncidentNumber = NULL
		, ChangeNumber = number
		, Contents = ' + COLUMN_NAME + '
	FROM
		[$(OGDW_Archive)].TOPdesk.' + TABLE_NAME + '
	WHERE 1=1
		AND ' + COLUMN_NAME + ' IS NOT NULL
		AND SourceDatabaseKey = ' + CAST(SourceDatabaseKey AS nvarchar(10)) + ''
FROM
	etl.CustomColumns
WHERE 1=1
	AND ColumnDefinition = 'Procesfeedback'
	AND TABLE_NAME = 'change'
)

DECLARE @SQLString nvarchar(max)

-- Voer de gegenereerde statements uit
OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @SQLString
WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRANSACTION
	EXEC (@SQLString)
	COMMIT TRANSACTION
	FETCH NEXT FROM ExecuteBatches INTO @SQLString
END
CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

/*
Alle procesfeedback van alle SDKs staan nu in een temp tabel. Per melding worden alle memo's in één
memoveld opgeslagen. Deze moeten nu gesplitst worden en apart opgeslagen in een nieuwe temp tabel met
bijbehorende meta data. Het memoveld is (in principe) als volgt opgebouwd:

datum-spatie-operator-dubbelepunt-char(10)-memo-char(10)-char(10)
datum-spatie-operator-dubbelepunt-char(10)-memo-char(10)-char(10)
datum-spatie-operator-dubbelepunt-char(10)-memo
*/

-- Definieer de blanco tekens (spatie, tab, return) en het gebruikte standaard datumformaat
DECLARE @WhitespacePattern nvarchar(5) = char(0) + char(9) + char(10) + char(13) + char(32)
DECLARE @DatePattern nvarchar(16) = '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]'

DROP TABLE IF EXISTS #FactProcesFeedback
CREATE TABLE #FactProcesFeedback
(
	SourceDatabaseKey int
	, AuditDWKey int
	, IncidentNumber nvarchar(255)
	, ChangeNumber nvarchar(255)
	, CreationDate date
	, CreationTime time(0)
	, OperatorName nvarchar(255)
	, Memo nvarchar(max)
)

DECLARE ProcesFeedbacks CURSOR FOR
(
SELECT
	SourceDatabaseKey
	, AuditDWKey
	, IncidentNumber
	, ChangeNumber
	, Contents
FROM
	#ProcesFeedback
WHERE 1=1
-- Onderstaand zijn allemaal uitzonderingssituaties waarmee getest kan worden
--	AND naam IN ('1209 829','1203 1037','1503 1901') -- Tickets met datumpatroon in incident.vrijememo2
--	AND naam IN ('1202 605','1305 910','1403 2587','1403 891','1410 1603','1502 2340','1509 250') -- Tickets waarbij iemand een actie in incident.vrijememo2 geplakt heeft
--	AND naam IN ('1201 347','1205 1044','1306 754','1311 255','1403 809','1405 1872','1405 806','1406 2693','1406 382','1408 666',
--		'1409 2392','1410 492','1502 2214','1507 1784','1508 1474','1509 618','1510 603') -- Tickets met lege memo in incident.vrijememo2
)

DECLARE @SourceDatabaseKey int
DECLARE @AuditDWKey int
DECLARE @IncidentNumber nvarchar(255)
DECLARE @ChangeNumber nvarchar(255)
DECLARE @Contents nvarchar(max)

OPEN ProcesFeedbacks
FETCH NEXT FROM ProcesFeedbacks INTO @SourceDatabaseKey, @AuditDWKey, @IncidentNumber, @ChangeNumber, @Contents
WHILE @@FETCH_STATUS = 0 
BEGIN
	-- StartOfString bepaalt telkens het eerste niet-blanco teken in het memoveld
	DECLARE @StartOfString int

	DECLARE @CreationDate nvarchar(16)
	DECLARE @OperatorName nvarchar(100)
	DECLARE @Memo nvarchar(max)

	-- Voer de iteratie uit zolang er nog data in het memoveld zit
	WHILE LEN(@Contents) > 0
	BEGIN
		SET @StartOfString = PATINDEX('%[^' + @WhitespacePattern + ']%', @Contents)

		-- Bepaal bij het hoeveelste teken de eerstvolgende datum begint
		DECLARE @NextCreationDate int = PATINDEX('%' + @DatePattern + '%', @Contents)
		-- Als er nog een datum voorkomt
		IF @NextCreationDate > 0
		BEGIN
			-- Zet dan de CreationDate van de memo op deze datum
			SET @NextCreationDate = @NextCreationDate + LEN(@DatePattern)
			SET @CreationDate = SUBSTRING(@Contents, @StartOfString, @NextCreationDate - @StartOfString)
			-- En verwijder de datum en alles links hiervan uit het memoveld
			SET @Contents = RIGHT(@Contents, LEN(@Contents) - @NextCreationDate)
		END
		ELSE
		BEGIN
			-- Zet anders de CreationDate op de default waarde
			SET @CreationDate = CONVERT(datetime, '1753-01-01 12:00', 105)
		END

		SET @StartOfString = PATINDEX('%[^' + @WhitespacePattern + ']%', @Contents)

		-- Bepaal op basis van ':' bij het hoeveelste teken de eerstvolgende operator wordt vermeld (cq eindigt)
		DECLARE @NextOperator int = CHARINDEX(':', @Contents)
		-- Als er nog een operator voorkomt
		IF @NextCreationDate > 0 AND @NextOperator > 0
		BEGIN
			-- Zet dan de OperatorName van de memo op deze operator
			SET @OperatorName = SUBSTRING(@Contents, @StartOfString, @NextOperator - @StartOfString)
			-- En verwijder de operator en alles links hiervan uit het memoveld
			SET @Contents = RIGHT(@Contents, LEN(@Contents) - @NextOperator)
		END
		ELSE
		BEGIN
			-- Zet anders de CreationDate op de default waarde
			SET @OperatorName = ''
		END

		SET @StartOfString = PATINDEX('%[^' + @WhitespacePattern + ']%', @Contents)

		-- Bepaal of en bij welke teken er nog een memo volgt
		DECLARE @NextRecord int = PATINDEX('%' + char(10) + char(10) + @DatePattern + '%', @Contents)
		-- Als er hierna nog een memo voorkomt
		IF @NextRecord > 0
		BEGIN
			-- Zet dan de Memo op alles wat er nog resteert tot aan deze volgende memo
			-- Het IIF statement is nodig om gevallen van lege memo's af te vangen
			SET @Memo = IIF(@NextRecord > @StartOfString, SUBSTRING(@Contents, @StartOfString, @NextRecord - @StartOfString), '')
			-- En verwijder de memo en alles links hiervan uit het memoveld
			SET @Contents = RIGHT(@Contents, LEN(@Contents) - @NextRecord)
		END
		ELSE
		BEGIN
			-- Zet anders de Memo op alles wat er überhaupt nog resteert van het memoveld
			SET @Memo = SUBSTRING(@Contents, @StartOfString, LEN(@Contents) - @StartOfString + 1)
			-- En maak het memoveld leeg zodat de iteratie stopt
			SET @Contents = ''
		END

		-- Plaats de memo en de metadata in de temp tabel
		INSERT INTO
			#FactProcesFeedback
		SELECT
			SourceDatabaseKey = @SourceDatabaseKey
			, AuditDWKey = @AuditDWKey
			, IncidentNumber = @IncidentNumber
			, ChangeNumber = @ChangeNumber
			, CreationDate = CONVERT(date, @CreationDate, 105)
			, CreationTime = CONVERT(time(0), @CreationDate, 105)
			, OperatorName = @OperatorName
			, Memo = @Memo
	END
	FETCH NEXT FROM ProcesFeedbacks INTO @SourceDatabaseKey, @AuditDWKey, @IncidentNumber, @ChangeNumber, @Contents
END
CLOSE ProcesFeedbacks
DEALLOCATE ProcesFeedbacks

/*
Verplaats de inhoud van de temp tabel naar de fact tabel en zoek er de juiste IncidentKey en ChangeKey bij
*/

INSERT INTO
	[$(OGDW)].Fact.ProcesFeedback
	(
	ProcesFeedback_ID
	, SourceDatabaseKey
	, AuditDWKey
	, CustomerKey
	, IncidentKey
	, ChangeKey
	, CreationDate
	, CreationTime
	, OperatorName
	, Memo
	)
SELECT
	ProcesFeedback_ID = ROW_NUMBER() OVER (ORDER BY PF.SourceDatabaseKey)
	, PF.SourceDatabaseKey
	, PF.AuditDWKey
	, CustomerKey = COALESCE(I.CustomerKey, C.CustomerKey, -1)
	, IncidentKey = ISNULL(I.Incident_Id,-1)
	, ChangeKey = ISNULL(C.Change_Id,-1)
	, PF.CreationDate
	, PF.CreationTime
	, PF.OperatorName
	, PF.Memo
FROM
	#FactProcesFeedback PF
	LEFT OUTER JOIN [$(OGDW)].Fact.Incident I ON PF.IncidentNumber = I.IncidentNumber AND PF.SourceDatabaseKey = I.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Fact.Change C ON PF.ChangeNumber = C.ChangeNumber AND PF.SourceDatabaseKey = C.SourceDatabaseKey

SET @newRowCount += @@ROWCOUNT
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