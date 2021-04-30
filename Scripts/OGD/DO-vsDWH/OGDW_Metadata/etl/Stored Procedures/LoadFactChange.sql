CREATE PROCEDURE [etl].[LoadFactChange]
(
	@delta bit = 0
)
AS
BEGIN

/***************************************************************************************************
* Fact.Change
****************************************************************************************************
* 2016-12-21 * WvdS	* FirstTimeRight kolom toegevoegd zoals aangevraagd door SanderL https://trello.com/c/ExPVRSaJ
* 2016-12-21 * WvdS	* Opmaak bijgewerkt
* 2017-01-12 * WvdS	* Kijk naar OGDW_Archive ipv OGDW_AM
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
	DELETE FROM [$(OGDW)].Fact.Change
	DBCC CHECKIDENT ('[$(OGDW)].Fact.Change', RESEED, 0)

	-- Insert default line
	SET IDENTITY_INSERT [$(OGDW)].Fact.Change ON
	INSERT INTO
		[$(OGDW)].Fact.Change (Change_Id, SourceDatabaseKey, AuditDWKey, CustomerKey, CallerKey, OperatorGroupKey, CurrentPhaseSTD, TypeSTD)
	VALUES
		(-1, -1, -1, -1, -1, -1, -1, '[Onbekend]')
	SET @newRowCount += @@ROWCOUNT
	SET IDENTITY_INSERT [$(OGDW)].Fact.Change OFF
END
ELSE
BEGIN
	DELETE f FROM
		[$(OGDW)].Fact.Change f
	WHERE 1=1
		AND EXISTS (
			SELECT
				ChangeNumber
			FROM
				etl.Translated_Change t
			WHERE 1=1
				AND t.AuditDWKey > (SELECT MAX(AuditDWKey) FROM [$(OGDW)].Fact.Change)
				AND f.SourceDatabaseKey = t.SourceDatabaseKey
				AND f.ChangeNumber = t.ChangeNumber
			)
END

INSERT INTO
	[$(OGDW)].Fact.Change
	(
	SourceDatabaseKey
	, AuditDWKey
	, CustomerKey
	, CallerKey
	, OperatorGroupKey
	, Category
	, CardChangedBy
	, ChangeDate
	, ChangeTime
	, ClosureDateSimpleChange
	, ClosureTimeSimpleChange
	, Closed
	, CardCreatedBy
	, CustomerName
	, ExternalNumber
	, Impact
	, ChangeNumber
	, ObjectID
	, [Priority]
	, [Status]
	, Subcategory
	, AuthorizationDate
	, AuthorizationTime
	, CancelDateExtChange
	, CancelTimeExtChange
	, CancelledByManager
	, CancelledByOperator
	, ChangeType
	, Coordinator
	, CreationDate
	, CreationTime
	, CurrentPhase
	, CurrentPhaseSTD
	, DateCalcTypeEvaluation
	, DateCalcTypeProgress
	, DateCalcTypeRequestChange
	, DescriptionBrief
	, EndDateExtChange
	, EndTimeExtChange
	, Evaluation
	, ImplDateExtChange
	, ImplTimeExtChange
	, ImplDateSimpleChange
	, ImplTimeSimpleChange
	, Implemented
--	, MajorIncidentId
	, NoGoDateExtChange
	, NoGoTimeExtChange
	, OperatorEvaluationExtChange
	, OperatorProgressExtChange
	, OperatorRequestChange
	, OperatorSimpleChange
	, OriginalIncident
	, PlannedAuthDateRequestChange
	, PlannedAuthTimeRequestChange
	, PlannedFinalDate
	, PlannedFinalTime
	, PlannedImplDate
	, PlannedImplTime
	, PlannedStartDateSimpleChange
	, PlannedStartTimeSimpleChange
	, ProcessingStatus
	, Rejected
	, RejectionDate
	, RejectionTime
	, RequestDate
	, RequestTime
	, StartDateSimpleChange
	, StartTimeSimpleChange
	, [Started]
	, SubmissionDateRequestChange
	, SubmissionTimeRequestChange
	, Template
	, TimeSpent
	, [Type]
	, TypeSTD
	, Urgency
	, ClosureDate
	, ClosureTime
	, CompletionDate
	, CompletionTime
	, RequestedBy
	, FirstTimeRight
	)
SELECT
	CH.SourceDatabaseKey
	, CH.AuditDWKey

	-- Voor Multi-klant topdesk in de FileImport staat de Customer in de kolom [CustomerName], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Multi-klant topdesk in de database staat de Customer in [vestiging].[naam], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Single-klant topdesk in de FileImport is de kolom [CustomerName] = NULL en wordt de naam dus opgehaald via SourceDefinition
	-- Voor Single-klant topdesk in de database bevat de kolom [vestiging].[naam] daadwerkelijk de vestiging; halen we de Customer dus op via SourceDefinition
	-- Via onderstaande regel zou altijd een CustomerKey gevonden moeten worden, tenzij er geen vertaling gedefinieerd is
	, CustomerKey = ISNULL(CAST(CASE
			WHEN SD.MultipleCustomers = 0 THEN C1.Code -- Klantnaam via SourceDefinition
			ELSE ISNULL(C2.Code,-1) -- Klantnaam uit CustomerName veld, vertaald via SourceTranslation naar CustomerKey
		END AS int),-1) -- Bij gegevens uit de database moet deze key op een andere manier worden bepaald
	, CallerKey = ISNULL(CH.CallerKey,-1)
	, OperatorGroupKey = ISNULL(CH.OperatorGroupKey,-1)

	, CH.Category
	, CH.CardChangedBy
	, CH.ChangeDate
	, CH.ChangeTime
	, CH.ClosureDateSimpleChange
	, CH.ClosureTimeSimpleChange
	, CH.Closed
	, CH.CardCreatedBy
	, CH.CustomerName
	, CH.ExternalNumber
	, CH.Impact
	, CH.ChangeNumber
	, CH.ObjectID
	, CH.[Priority]
	, CH.[Status]
	, CH.Subcategory
	, CH.AuthorizationDate
	, CH.AuthorizationTime
	, CH.CancelDateExtChange
	, CH.CancelTimeExtChange
	, CH.CancelledByManager
	, CH.CancelledByOperator
	, CH.ChangeType
	, CH.Coordinator
	, CH.CreationDate
	, CH.CreationTime
	, CH.CurrentPhase
	, CH.CurrentPhaseSTD
	, CH.DateCalcTypeEvaluation
	, CH.DateCalcTypeProgress
	, CH.DateCalcTypeRequestChange
	, CH.DescriptionBrief
	, CH.EndDateExtChange
	, CH.EndTimeExtChange
	, CH.Evaluation
	, CH.ImplDateExtChange
	, CH.ImplTimeExtChange
	, CH.ImplDateSimpleChange
	, CH.ImplTimeSimpleChange
	, CH.Implemented
--	, CH.MajorIncidentId
	, CH.NoGoDateExtChange
	, CH.NoGoTimeExtChange
	, CH.OperatorEvaluationExtChange
	, CH.OperatorProgressExtChange
	, CH.OperatorRequestChange
	, CH.OperatorSimpleChange
	, CH.OriginalIncident
	, CH.PlannedAuthDateRequestChange
	, CH.PlannedAuthTimeRequestChange
	, CH.PlannedFinalDate
	, CH.PlannedFinalTime
	, CH.PlannedImplDate
	, CH.PlannedImplTime
	, CH.PlannedStartDateSimpleChange
	, CH.PlannedStartTimeSimpleChange
	, CH.ProcessingStatus
	, CH.Rejected
	, CH.RejectionDate
	, CH.RejectionTime
	, CH.RequestDate
	, CH.RequestTime
	, CH.StartDateSimpleChange
	, CH.StartTimeSimpleChange
	, CH.[Started]
	, CH.SubmissionDateRequestChange
	, CH.SubmissionTimeRequestChange
	, CH.Template
	, CH.TimeSpent
	, CH.[Type]
	, CH.TypeSTD
	, CH.Urgency

	-- Vanaf hier extra calculated columns

	-- Een kolom die per change kijkt wat de datum is dat hij is gesloten. Dit kan de datum zijn dat hij afgerond is, maar ook afgewezen of geannuleerd.
	-- Ook is het mogelijk dat de EndDate niet is ingevuld maar de status wel 'Afgeronde uitgebreide wijziging' is, in dat geval wordt de implementatiedatum genomen.
	, ClosureDate = COALESCE(EndDateExtChange,ClosureDateSimpleChange,CancelDateExtChange,RejectionDate,IIF(CurrentPhaseSTD IN ('Afgeronde uitgebreide wijziging'),ImplDateExtChange,NULL))
	, ClosureTime = COALESCE(EndTimeExtChange,ClosureTimeSimpleChange,CancelTimeExtChange,RejectionTime,IIF(CurrentPhaseSTD IN ('Afgeronde uitgebreide wijziging'),ImplTimeExtChange,NULL))

	-- Hetzelfde wordt gedaan voor de gereeddatum.
	, CompletionDate = COALESCE(ImplDateExtChange,EndDateExtChange,ClosureDateSimpleChange,CancelDateExtChange,RejectionDate)
	, CompletionTime = COALESCE(ImplTimeExtChange,EndTimeExtChange,ClosureTimeSimpleChange,CancelTimeExtChange,RejectionTime)

	-- De volgende twee kolommen zijn alleen van toepassing op MKBO (SourceDatabaseKey=40)
	-- Servicedesk medewerkers selecteren de aanvrager van wijziging uit een dropdown lijst (OGD / Klant)
	, RequestedBy =
	(
		SELECT DISTINCT
			ISNULL(v.naam,'[Niet gespecificeerd]')
		FROM
			[$(OGDW_Archive)].TOPdesk.change c
			LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.vrijeopzoekvelden v ON c.vrijeopzoek3 = v.unid
		WHERE 1=1
			AND c.SourceDatabaseKey = 40
			AND c.number = CH.ChangeNumber
			AND c.SourceDatabaseKey = CH.SourceDatabaseKey
	)

	-- Servicedesk medewerkers zetten een vinkje aan wanneer een wijziging bij de eerste poging correct werd geïmplementeerd ten opzichte van de 
	-- functionele vraag aan begin van het traject, dus zonder een aanpassing te hoeven doen na de eerste functionele test van de aanvrager (0 / 1)
	, FirstTimeRight =
	(
		SELECT DISTINCT
			vrijelogisch3
		FROM
			[$(OGDW_Archive)].TOPdesk.change c
		WHERE 1=1
			AND c.SourceDatabaseKey = 40
			AND c.number = CH.ChangeNumber
			AND c.SourceDatabaseKey = CH.SourceDatabaseKey
	)

FROM
	etl.Translated_Change CH
	LEFT OUTER JOIN setup.SourceDefinition SD ON CH.SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.DimCustomer C1 ON SD.DatabaseLabel = C1.[Name]
	LEFT OUTER JOIN setup.SourceTranslation ST ON CH.CustomerName = ST.SourceValue AND SD.DatabaseLabel = ST.SourceName
		AND ST.DWColumnName = 'CustomerName' AND TranslatedColumnName = 'CustomerAbbreviation'
	LEFT OUTER JOIN setup.DimCustomer C2 ON ST.TranslatedValue = C2.[Name]
WHERE 1=1
	AND AuditDWKey > CASE WHEN @delta = 0 THEN 0 ELSE (SELECT MAX(AuditDWKey) FROM [$(OGDW)].Fact.Change) END

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