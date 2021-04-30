CREATE PROCEDURE [etl].[LoadFactProbleemVermoeden]
AS
BEGIN

/***************************************************************************************************
* [etl].[LoadFactProbleemVermoeden]
****************************************************************************************************
* Mogelijk probleem: wat gebeurt er als de memo in een kolom staat die nog niet gestaged wordt?
* Code overlapt erg met LoadProcesFeedback
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

DELETE FROM [$(OGDW)].Fact.ProbleemVermoeden

/*
Omdat de probleemvermoedens in de brontabellen in verschillende kolommen staan, kan deze niet zomaar 1-op-1
worden overgenomen, maar moet deze middels dynamische sql eerst in een temp tabel worden geladen. In de
tabel etl.CustomColumns staat voor iedere SDK beschreven in welke kolom de data staat.
*/

DROP TABLE IF EXISTS #ProbleemVermoeden
CREATE TABLE #ProbleemVermoeden
(
	SourceDatabaseKey int
	, AuditDWKey int
	, IncidentNumber nvarchar(255)
	, Contents nvarchar(max)
)

-- Genereer het INSERT statement voor iedere SDK
DECLARE ExecuteBatches CURSOR FOR
(
SELECT SQLString = '
	INSERT INTO
		#ProbleemVermoeden
	SELECT
		SourceDatabaseKey
		, AuditDWKey
		, IncidentNumber = naam
		, Contents = ' + COLUMN_NAME + '
	FROM
		[$(OGDW_Archive)].TOPdesk.' + TABLE_NAME + '
	WHERE 1=1
		AND ' + COLUMN_NAME + ' IS NOT NULL
		AND SourceDatabaseKey = ' + CAST(SourceDatabaseKey AS nvarchar(10)) + ''
FROM
	etl.CustomColumns
WHERE 1=1
	AND ColumnDefinition = 'Probleemvermoeden'
	AND TABLE_NAME = 'incident'
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
Alle probleemvermoedens van alle SDKs staan nu in een temp tabel. Per melding worden alle memo's in één
memoveld opgeslagen. Deze moeten nu gesplitst worden en apart opgeslagen in een nieuwe temp tabel met
bijbehorende meta data. Het memoveld is (in principe) als volgt opgebouwd:

datum-spatie-operator-dubbelepunt-char(10)-memo-char(10)-char(10)
datum-spatie-operator-dubbelepunt-char(10)-memo-char(10)-char(10)
datum-spatie-operator-dubbelepunt-char(10)-memo
*/

-- Definieer de blanco tekens (spatie, tab, return) en het gebruikte standaard datumformaat
DECLARE @WhitespacePattern nvarchar(5) = char(0) + char(9) + char(10) + char(13) + char(32)
DECLARE @DatePattern nvarchar(16) = '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9] [0-9][0-9]:[0-9][0-9]'

DROP TABLE IF EXISTS #FactProbleemVermoeden
CREATE TABLE #FactProbleemVermoeden
(
	SourceDatabaseKey int
	, AuditDWKey int
	, IncidentNumber nvarchar(255)
	, CreationDate date
	, CreationTime time(0)
	, OperatorName nvarchar(255)
	, Memo nvarchar(max)
)

DECLARE ProbleemVermoedens CURSOR FOR
(
SELECT
	SourceDatabaseKey
	, AuditDWKey
	, IncidentNumber
	, Contents
FROM
	#ProbleemVermoeden
)

DECLARE @SourceDatabaseKey int
DECLARE @AuditDWKey int
DECLARE @IncidentNumber nvarchar(255)
DECLARE @Contents nvarchar(max)

OPEN ProbleemVermoedens
FETCH NEXT FROM ProbleemVermoedens INTO @SourceDatabaseKey, @AuditDWKey, @IncidentNumber, @Contents
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
			#FactProbleemVermoeden
		SELECT
			SourceDatabaseKey = @SourceDatabaseKey
			, AuditDWKey = @AuditDWKey
			, IncidentNumber = @IncidentNumber
			, CreationDate = CONVERT(date, @CreationDate, 105)
			, CreationTime = CONVERT(time(0), @CreationDate, 105)
			, OperatorName = @OperatorName
			, Memo = @Memo
	END
	FETCH NEXT FROM ProbleemVermoedens INTO @SourceDatabaseKey, @AuditDWKey, @IncidentNumber, @Contents
END
CLOSE ProbleemVermoedens
DEALLOCATE ProbleemVermoedens

/*
Verplaats de inhoud van de temp tabel naar de fact tabel en zoek er de juiste IncidentKey bij
*/

INSERT INTO
	[$(OGDW)].Fact.ProbleemVermoeden
	(
	ProbleemVermoeden_ID
	, SourceDatabaseKey
	, AuditDWKey
	, CustomerKey
	, IncidentKey
	, CreationDate
	, CreationTime
	, OperatorName
	, Memo
	)
SELECT
	ProbleemVermoeden_ID = ROW_NUMBER() OVER (ORDER BY PV.SourceDatabaseKey)
	, PV.SourceDatabaseKey
	, PV.AuditDWKey
	, CustomerKey = ISNULL(I.CustomerKey,-1)
	, IncidentKey = ISNULL(I.Incident_Id,-1)
	, PV.CreationDate
	, PV.CreationTime
	, PV.OperatorName
	, PV.Memo
FROM
	#FactProbleemVermoeden PV
	LEFT OUTER JOIN [$(OGDW)].Fact.Incident I ON PV.IncidentNumber = I.IncidentNumber AND PV.SourceDatabaseKey = I.SourceDatabaseKey

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