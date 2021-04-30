CREATE PROCEDURE [etl].[LoadDimOperatorGroup]
AS
BEGIN

/***************************************************************************************************
* [etl].[LoadDimOperatorGroup]
****************************************************************************************************
* Deze procedure maakt de dimensie voor OperatorGroup aan op basis van data in OGDW_Archive
* Todo: (1) De Jutters zijn geen klant meer is en de DB is ook niet meer beschikbaar, waardoor
* nieuwe kolommen niet kunnen worden opgehaald. Wat doen we hiermee?
* (2) Daarom wordt er nog gebruik gemaakt van ref_operatorgroup als backup voor operatorgroupid
* (3) In deze solution bevat OGDW_Archive nog niet operatorgroupid
****************************************************************************************************
* 2017-01-11 * WvdS  * Eerste versie
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

DELETE FROM [$(OGDW)].Dim.OperatorGroup
DBCC CHECKIDENT ('[$(OGDW)].Dim.OperatorGroup', RESEED, 0)

-- Insert default line
SET IDENTITY_INSERT [$(OGDW)].Dim.OperatorGroup ON
INSERT INTO
	[$(OGDW)].Dim.OperatorGroup (OperatorGroupKey, SourceDatabaseKey, OperatorGroup, OperatorGroupSTD)
VALUES
	(-1, -1, '[Onbekend]', '[Onbekend]')
SET @newRowCount += @@ROWCOUNT
SET IDENTITY_INSERT [$(OGDW)].Dim.OperatorGroup OFF

-- onderstaande unions gebruiken diverse ticket tabellen om een unieke lijst van opgeratorgroups per sourcedatabase te selecteren.
;WITH Tickets AS
(
SELECT 
	i.SourceDatabaseKey
	, OperatorGroupID = a.unid
	, OperatorGroup = a.naam
FROM
	[$(OGDW_Archive)].TOPdesk.actiedoor a
	INNER JOIN [$(OGDW_Archive)].TOPdesk.incident i ON a.unid = i.operatorgroupid AND a.SourceDatabaseKey = i.SourceDatabaseKey
WHERE 1=1
	AND a.naam <> ''

UNION 

SELECT 
	c.SourceDatabaseKey
	, OperatorGroupID = a.unid
	, OperatorGroup = a.naam
FROM
	[$(OGDW_Archive)].TOPdesk.actiedoor a
	INNER JOIN [$(OGDW_Archive)].TOPdesk.change c ON a.unid = c.operatorgroupid AND a.SourceDatabaseKey = c.SourceDatabaseKey
WHERE 1=1
	AND a.naam <> ''

UNION

SELECT 
	p.SourceDatabaseKey
	, OperatorGroupID = a.unid
	, OperatorGroup = a.naam
FROM
	[$(OGDW_Archive)].TOPdesk.actiedoor a
	INNER JOIN [$(OGDW_Archive)].TOPdesk.probleem p ON a.unid = p.operatorgroupid AND a.SourceDatabaseKey = p.SourceDatabaseKey
WHERE 1=1
	AND a.naam <> ''

UNION

SELECT 
	ca.SourceDatabaseKey
	, OperatorGroupID = a.unid
	, OperatorGroup = a.naam
FROM
	[$(OGDW_Archive)].TOPdesk.actiedoor a
	INNER JOIN [$(OGDW_Archive)].TOPdesk.changeactivity ca ON a.unid = ca.operatorgroupid AND a.SourceDatabaseKey = ca.SourceDatabaseKey
WHERE 1=1
	AND a.naam <> ''

UNION

SELECT 
	oa.SourceDatabaseKey
	, OperatorGroupID = a.unid
	, OperatorGroup = a.naam
FROM
	[$(OGDW_Archive)].TOPdesk.actiedoor a
	INNER JOIN [$(OGDW_Archive)].TOPdesk.[om_activiteit] oa ON a.unid = oa.operatorgroupid AND a.SourceDatabaseKey = oa.SourceDatabaseKey
WHERE 1=1
	AND a.naam <> ''

UNION

SELECT DISTINCT
	SourceDatabaseKey
	, OperatorGroupID = NULL
	, OperatorGroup
FROM
	[$(OGDW_Archive)].FileImport.Incidents
)

INSERT INTO
	[$(OGDW)].Dim.OperatorGroup
	(
	SourceDatabaseKey
	, OperatorGroupID
	, OperatorGroup
	, OperatorGroupSTD
	)
SELECT
	SourceDatabaseKey
	, OperatorGroupID
	, OperatorGroup = ISNULL(NULLIF(OperatorGroup,''),'[Geen]')
	, OperatorGroupSTD = COALESCE(T00.TranslatedValue, TD00.TranslatedValue, '[Onbekend]')
FROM
	Tickets t
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = t.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceTranslation T00 ON T00.SourceName = SD.DatabaseLabel 
		AND T00.AMAnchorName = 'OperatorGroup'
		AND T00.DWColumnName = 'OperatorGroup'
		AND ISNULL(T00.SourceValue,-1) = ISNULL(CAST(t.OperatorGroup AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD00 ON TD00.SourceName = 'DEFAULT'
		AND TD00.AMAnchorName = 'OperatorGroup'
		AND TD00.DWColumnName = 'OperatorGroup'
		AND ISNULL(TD00.SourceValue,-1) = ISNULL(CAST(t.OperatorGroup AS varchar(max)),'-1')

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