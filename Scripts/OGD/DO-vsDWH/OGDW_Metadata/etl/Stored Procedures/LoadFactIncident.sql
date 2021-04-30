CREATE PROCEDURE [etl].[LoadFactIncident]
(
	@delta bit = 0
)
AS
BEGIN

/***************************************************************************************************
* Fact.Incident
****************************************************************************************************
* 2016-12-22 * WvdS	* Werk opmaak bij
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

IF @delta = 0
BEGIN
	DELETE FROM [$(OGDW)].Fact.Incident
	DBCC CHECKIDENT ('[$(OGDW)].Fact.Incident', RESEED, 0)

	-- Insert default line
	SET IDENTITY_INSERT [$(OGDW)].Fact.Incident ON
	INSERT INTO
		[$(OGDW)].Fact.Incident (Incident_Id, SourceDatabaseKey, AuditDWKey, CustomerKey, CallerKey, OperatorGroupKey, ObjectKey, EntryTypeSTD, PrioritySTD, StatusSTD, IncidentTypeSTD)
	VALUES
		(-1, -1, -1, -1, -1, -1, -1, '[Onbekend]', '[Onbekend]', '[Onbekend]', '[Onbekend]')
	SET @newRowCount += @@ROWCOUNT
	SET IDENTITY_INSERT [$(OGDW)].Fact.Incident OFF
END
ELSE
BEGIN
	DELETE f FROM
		[$(OGDW)].Fact.Incident f
	WHERE 1=1
		AND EXISTS (
			SELECT
				IncidentNumber
			FROM
				etl.Translated_Incident t
			WHERE 1=1
				AND t.AuditDWKey > (SELECT MAX(AuditDWKey) FROM [$(OGDW)].Fact.Incident)
				AND f.SourceDatabaseKey = t.SourceDatabaseKey
				AND f.IncidentNumber = t.IncidentNumber
			)
END
	  
INSERT INTO
	[$(OGDW)].Fact.Incident
	(
	SourceDatabaseKey
	, AuditDWKey
	, CustomerKey
	, CallerKey
	, OperatorGroupKey
	, ObjectKey
	, DurationActual
	, DurationAdjusted
	, Category
	, ConfigurationID
	, CardChangedBy
	, ChangeDate
	, ChangeTime
	, ClosureDate
	, ClosureTime
	, Closed
	, CompletionDate
	, CompletionTime
	, Completed
	, CardCreatedBy
	, CreationDate
	, CreationTime
	, CustomerName
	, CustomerAbbreviation
	, IncidentDescription
	, DurationOnHold
	, Duration
	, EntryType
	, EntryTypeSTD
	, ExternalNumber
	, OnHold
	, IsMajorIncident
	, Impact
	, IncidentDate
	, IncidentTime
	, Line
	, MajorIncident
	, IncidentNumber
	, OnHoldDate
	, OnHoldTime
	, ObjectID
	, [Priority]
	, PrioritySTD
	, Sla
	, SlaContract
	, StandardSolution
	, [Status]
	, StatusSTD
	, SlaTargetDate
	, SlaTargetTime
	, Subcategory
	, Supplier
	, ServiceWindow
	, TargetDate
	, TargetTime
	, TimeSpentFirstLine
	, TotalTime
	, TimeSpentSecondLine
	, IncidentType
	, IncidentTypeSTD
	, SlaAchieved
	, DurationAdjustedActualCombi
	, SlaAchievedFlag
	, HandledByOGD
	, Bounced
	)
SELECT
	[IN].SourceDatabaseKey
	, [IN].AuditDWKey

	-- Voor Multi-klant topdesk in de FileImport staat de Customer in de kolom [CustomerName], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Multi-klant topdesk in de database staat de Customer in [vestiging].[naam], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Single-klant topdesk in de FileImport is de kolom [CustomerName] = NULL en wordt de naam dus opgehaald via SourceDefinition
	-- Voor Single-klant topdesk in de database bevat de kolom [vestiging].[naam] daadwerkelijk de vestiging; halen we de Customer dus op via SourceDefinition
	-- Via onderstaande regel zou altijd een CustomerKey gevonden moeten worden, tenzij er geen vertaling gedefinieerd is
	, CustomerKey = ISNULL(CAST(CASE
			WHEN SD.MultipleCustomers = 0 THEN C1.Code -- Klantnaam via SourceDefinition
			ELSE ISNULL(C2.Code,-1) -- Klantnaam uit CustomerName veld, vertaald via SourceTranslation naar CustomerKey
		END AS int),-1) -- Bij gegevens uit de database moet deze key op een andere manier worden bepaald
	, CallerKey = ISNULL([IN].CallerKey,-1)
	, OperatorGroupKey = ISNULL([IN].OperatorGroupKey,-1)
	, ObjectKey = ISNULL([IN].ObjectKey,-1)

	, [IN].DurationActual
	, [IN].DurationAdjusted
	, [IN].Category
	, [IN].ConfigurationID
	, [IN].CardChangedBy
	, [IN].ChangeDate
	, [IN].ChangeTime
	, [IN].ClosureDate
	, [IN].ClosureTime
	, [IN].Closed
	, [IN].CompletionDate
	, [IN].CompletionTime
	, [IN].Completed
	, [IN].CardCreatedBy
	, [IN].CreationDate
	, [IN].CreationTime
	, [IN].CustomerName
	, [IN].CustomerAbbreviation
	, [IN].IncidentDescription
	, [IN].DurationOnHold
	, [IN].Duration
	, [IN].EntryType
	, [IN].EntryTypeSTD
	, [IN].ExternalNumber
	, [IN].OnHold
	, [IN].IsMajorIncident
	, [IN].Impact
	, [IN].IncidentDate
	, [IN].IncidentTime
	, [IN].Line
	, [IN].MajorIncident
	, [IN].IncidentNumber
	, [IN].OnHoldDate
	, [IN].OnHoldTime
	, [IN].ObjectID
	, [IN].[Priority]
	, [IN].PrioritySTD
	, [IN].Sla
	, [IN].SlaContract
	, [IN].StandardSolution
	, [IN].[Status]
	, [IN].StatusSTD
	, [IN].SlaTargetDate
	, [IN].SlaTargetTime
	, [IN].Subcategory
	, [IN].Supplier
	, [IN].ServiceWindow
	, [IN].TargetDate
	, [IN].TargetTime
	, [IN].TimeSpentFirstLine
	, [IN].TotalTime
	, [IN].TimeSpentSecondLine
	, [IN].IncidentType
	, [IN].IncidentTypeSTD
	, [IN].SlaAchieved

	-- Vanaf hier extra calculated columns

	, DurationAdjustedActualCombi = ISNULL(DurationAdjusted,DurationActual)
	, SlaAchievedFlag = CASE COALESCE(SlaAchieved,'')
			WHEN '' THEN -1
			WHEN 'Achieved' THEN 1
			WHEN 'Breached' THEN 0
			WHEN 'Breached, being processed' THEN 0
			WHEN 'Gehaald' THEN 1
			WHEN 'Niet gebruikt' THEN -1
			WHEN 'Niet gehaald' THEN 0
			WHEN 'Niet gehaald, nog in behandeling' THEN 0
			WHEN 'Niet van toepassing' THEN -1
			WHEN 'Nog in behandeling' THEN -1
			WHEN 'Not applicable' THEN -1
			WHEN 'Still being processed' THEN -1
			ELSE -2
		END
	, HandledbyOGD = null
	, Bounced = null

--INTO
--	OGDW.Fact.Incident
--SELECT TOP 1 * FROM OGDW_Metadata.dbo.Translated_Incident [IN]

FROM
	etl.Translated_Incident [IN]
	LEFT OUTER JOIN setup.SourceDefinition SD ON [IN].SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.DimCustomer C1 ON SD.DatabaseLabel = C1.[Name]
	LEFT OUTER JOIN setup.SourceTranslation ST ON [IN].CustomerName = ST.SourceValue AND SD.DatabaseLabel = ST.SourceName
		AND ST.DWColumnName = 'CustomerName' AND TranslatedColumnName = 'CustomerAbbreviation'
	LEFT OUTER JOIN setup.DimCustomer C2 ON ST.TranslatedValue = C2.[Name]
WHERE 1=1
	AND AuditDWKey > CASE WHEN @delta = 0 THEN 0 ELSE (SELECT MAX(AuditDWKey) FROM [$(OGDW)].Fact.Incident) END


-- Ondersteunende TempTable voor HandledByOGD. Deze verzamelt alle wijzigingen van alle incidenten.

IF OBJECT_ID('tempdb..#UnionMutaties', 'U') IS NOT NULL 
DROP TABLE #UnionMutaties

SELECT * INTO #UnionMutaties 
FROM
(
SELECT parentid, uidwijzig, SourceDatabaseKey
FROM [$(OGDW_Archive)].TOPdesk.incident__memogeschiedenis
UNION ALL
SELECT parentid, uidwijzig, SourceDatabaseKey
FROM [$(OGDW_Archive)].TOPdesk.mutatie_incident
)x

CREATE CLUSTERED INDEX CI_UnionMutaties  ON #UnionMutaties (parentid , SourceDatabaseKey)

-- Deze TempTable bepaalt of een melding op enig moment is behandeld door een OGD'er. Een OGD'er wordt gedefinieerd als zijnde iemand bij wie als vestiging
-- 'OGD%' is ingevuld, als loginnaam 'OGD_%' heeft of een mailadres heeft eindigend op '@ogd.nl'. Het resultaat is 0 of 1.
IF OBJECT_ID('tempdb..#HandledByOGD', 'U') IS NOT NULL 
DROP TABLE #HandledByOGD

SELECT * INTO #HandledByOGD 
FROM
(
SELECT
	i.SourceDatabaseKey
	, i.naam
	, HandledByOGD = CEILING(AVG(CASE WHEN v.naam LIKE 'OGD%' OR a.tasloginnaam LIKE 'OGD_%' OR a.email LIKE '%@ogd.nl' THEN 1.0 ELSE 0.0 END))
FROM
	#UnionMutaties m
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.incident i ON m.parentid = i.unid AND m.SourceDatabaseKey = i.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.gebruiker g ON m.uidwijzig = g.unid AND m.SourceDatabaseKey = g.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.actiedoor a ON g.unid = a.loginnaamtopdeskid AND g.SourceDatabaseKey = a.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.vestiging v ON a.vestigingid = v.unid AND a.SourceDatabaseKey = v.SourceDatabaseKey
GROUP BY
	i.SourceDatabaseKey
	, i.naam
)x

CREATE CLUSTERED INDEX CI_HandledByOGD ON #HandledByOGD (SourceDatabaseKey , naam)

UPDATE [in] 
SET [in].HandledByOGD = h.HandledByOGD
FROM [$(OGDW)].Fact.Incident [IN] 
JOIN #HandledByOGD h on h.naam = [IN].IncidentNumber AND h.SourceDatabaseKey = [IN].SourceDatabaseKey


-- Deze TempTable bepaalt hoe vaak een melding van niet-servicedesk naar servicedesk is gegaan. Dit zou een indicatie kunnen zijn van een bounce, oftewel
-- een melding die geweigerd is door een behandelaar omdat deze niet goed door de servicedesk is uitgevraagd of ingevuld.
IF OBJECT_ID('tempdb..#Bounced', 'U') IS NOT NULL 
DROP TABLE #Bounced

SELECT * INTO  #Bounced
FROM
(
SELECT
	i.SourceDatabaseKey
	, i.naam
	, bounced = SUM(CASE WHEN og1.ref_dynanaam <> 'SERVICEDESK' AND ISNULL(og2.ref_dynanaam,i.ref_operatorgroup) = 'SERVICEDESK' THEN 1 ELSE 0 END)
FROM
	[$(OGDW_Archive)].TOPdesk.incident i
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.mutatie_incident m ON i.unid = m.parentid AND i.SourceDatabaseKey = m.SourceDatabaseKey AND m.mut_operatorgroupid IS NOT NULL
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.actiedoor og1 ON m.mut_operatorgroupid = og1.unid AND m.SourceDatabaseKey = og1.SourceDatabaseKey
	OUTER APPLY (
		SELECT TOP 1 mut_operatorgroupid, SourceDatabaseKey
		FROM [$(OGDW_Archive)].TOPdesk.mutatie_incident m1
		WHERE m1.datwijzig > m.datwijzig AND i.unid = m1.parentid AND i.SourceDatabaseKey = m1.SourceDatabaseKey AND m1.mut_operatorgroupid IS NOT NULL
		ORDER BY datwijzig
		) m2
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.actiedoor og2 ON m2.mut_operatorgroupid = og2.unid AND m2.SourceDatabaseKey = og2.SourceDatabaseKey
GROUP BY
	i.SourceDatabaseKey
	, i.naam
)  x

CREATE CLUSTERED INDEX IX_Bounced ON #Bounced(SourceDatabaseKey , naam)

UPDATE [in] 
SET [in].bounced = b.bounced
FROM [$(OGDW)].Fact.Incident [IN] 
JOIN #Bounced b on  b.naam = [IN].IncidentNumber AND b.SourceDatabaseKey = [IN].SourceDatabaseKey

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