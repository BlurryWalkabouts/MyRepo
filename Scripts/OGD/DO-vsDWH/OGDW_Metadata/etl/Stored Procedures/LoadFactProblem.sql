CREATE PROCEDURE [etl].[LoadFactProblem]
AS
BEGIN

/***************************************************************************************************
* Fact.Problem
****************************************************************************************************
* 2016-12-19 * WvdS	* Voeg ctePil, cteCpc, cteCpl, cteOpl en cteProblems toe en respectievelijke
*								kolommen, zoals aangevraagd door Gert-Jan https://trello.com/c/U7DZeXGn
* 2016-12-20 * WvdS	* Werk opmaak bij
* 2016-12-22 * WvdS	* Bugfix: Groepeer ctePil, cteCpc, cteCpl en cteOpl per SourceDatabaseKey
*							* Voeg een CAST() toe rondom [Incidents], [CausedByChanges], [FixedByChanges]
*								en [ObjectsImpacted], omdat deze kolommen in Fact.Problem als datatype
*								nvarchar(n) hebben, maar in de praktijk deze n zouden kunnen overschrijden.
*								Concreet houdt dit o.a. in dat de lijst van gekoppelde incidenten maximaal
*								uit zo'n ~360 tickets kan bestaan.
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

DELETE FROM [$(OGDW)].Fact.Problem
DBCC CHECKIDENT ('[$(OGDW)].Fact.Problem', RESEED, 0)

-- Ondersteunende CTE voor cteProblems
;WITH ctePil AS
(
SELECT
	i.SourceDatabaseKey
	, unid = l.probleemid
	, IncidentsCnt = COUNT(*)
	, IncidentsFirstReported = MIN(i.datumaangemeld)
	, IncidentsLastReported = MAX(i.datumaangemeld)
FROM
	[$(OGDW_Archive)].TOPdesk.probleemincidentlink l
	INNER JOIN [$(OGDW_Archive)].TOPdesk.incident i ON i.unid = l.incidentid AND i.SourceDatabaseKey = l.SourceDatabaseKey
GROUP BY
	i.SourceDatabaseKey
	, l.probleemid
)

-- Ondersteunende CTE voor cteProblems
, cteCpc AS
(
SELECT
	c.SourceDatabaseKey
	, unid = l.problemid
	, CausedByChangesCnt = COUNT(*)
	, CausedByChangesFirstExecuted = MIN(c.finaldate)
	, CausedByChangesLastExecuted = MAX(c.finaldate)
FROM
	[$(OGDW_Archive)].TOPdesk.change_problem_causedby_link l
	INNER JOIN [$(OGDW_Archive)].TOPdesk.change c ON c.unid = l.changeid AND c.SourceDatabaseKey = l.SourceDatabaseKey
GROUP BY
	c.SourceDatabaseKey
	, l.problemid
)

-- Ondersteunende CTE voor cteProblems
, cteCpl AS
(
SELECT
	c.SourceDatabaseKey
	, unid = l.problemid
	, FixedByChangesCnt = COUNT(*)
	, FixedByChangesFirstExecuted = MIN(c.finaldate)
	, FixedByChangesLastExecuted = MAX(c.finaldate)
FROM
	[$(OGDW_Archive)].TOPdesk.change_problem_link l
	INNER JOIN [$(OGDW_Archive)].TOPdesk.change c ON c.unid = l.changeid AND c.SourceDatabaseKey = l.SourceDatabaseKey
GROUP BY
	c.SourceDatabaseKey
	, l.problemid
)

-- Ondersteunende CTE voor cteProblems
, cteOpl AS
(
SELECT
	o.SourceDatabaseKey
	, unid = l.problemid
	, ObjectsImpactedCnt = COUNT(*)
FROM
	[$(OGDW_Archive)].TOPdesk.obj_problem_link l
	INNER JOIN [$(OGDW_Archive)].TOPdesk.[object] o ON o.unid = l.objectid AND o.SourceDatabaseKey = l.SourceDatabaseKey
GROUP BY
	o.SourceDatabaseKey
	, l.problemid
)

-- Deze CTE verzamelt alle informatie van de vorige vier CTEs mbt links tussen problemen, incidenten, wijzigingen en objecten
, cteProblems AS
(
SELECT
	p.SourceDatabaseKey
	, p.naam
	, CustomerName = v.naam
	, IncidentsCnt = COALESCE(pil.IncidentsCnt, 0)
	, IncidentsFirstReportedDate = CAST(pil.IncidentsFirstReported AS date)
	, IncidentsFirstReportedTime = CAST(pil.IncidentsFirstReported AS time(0))
	, IncidentsLastReportedDate = CAST(pil.IncidentsLastReported AS date)
	, IncidentsLastReportedTime = CAST(pil.IncidentsLastReported AS time(0))
	-- De volgende lijst kan maximaal uit 4000 tekens (zo'n 360 incidenten) bestaan, omdat dit het gekozen datatype in Fact.Problem is
	, Incidents = CAST(STUFF((
		SELECT ', ' + CAST(i.naam AS nvarchar(max))
		FROM [$(OGDW_Archive)].TOPdesk.incident i
		INNER JOIN [$(OGDW_Archive)].TOPdesk.probleemincidentlink l ON l.incidentid = i.unid AND i.SourceDatabaseKey = l.SourceDatabaseKey
		WHERE l.probleemid = p.unid
		ORDER BY i.datumaangemeld
		FOR XML PATH('')
		), 1, 2, '' ) AS nvarchar(4000))
	, CausedByChangesCnt = COALESCE(cpc.CausedByChangesCnt, 0)
	, CausedByChangesFirstExecutedDate = CAST(cpc.CausedByChangesFirstExecuted AS date)
	, CausedByChangesFirstExecutedTime = CAST(cpc.CausedByChangesFirstExecuted AS time(0))
	, CausedByChangesLastExecutedDate = CAST(cpc.CausedByChangesLastExecuted AS date)
	, CausedByChangesLastExecutedTime = CAST(cpc.CausedByChangesLastExecuted AS time(0))
	-- De volgende lijst kan maximaal uit 1024 tekens (zo'n 90 wijzigingen) bestaan, omdat dit het gekozen datatype in Fact.Problem is
	, CausedByChanges = CAST(STUFF((
		SELECT ', ' + CAST(c.number AS nvarchar(max))
		FROM [$(OGDW_Archive)].TOPdesk.change c
		INNER JOIN [$(OGDW_Archive)].TOPdesk.change_problem_causedby_link l ON l.changeid = c.unid AND c.SourceDatabaseKey = l.SourceDatabaseKey
		WHERE l.problemid = p.unid
		ORDER BY c.finaldate
		FOR XML PATH('')
		), 1, 2, '' ) AS nvarchar(1024))
	, FixedByChangesCnt = COALESCE(cpl.FixedByChangesCnt, 0)
	, FixedByChangesFirstExecutedDate = CAST(cpl.FixedByChangesFirstExecuted AS date)
	, FixedByChangesFirstExecutedTime = CAST(cpl.FixedByChangesFirstExecuted AS time(0))
	, FixedByChangesLastExecutedDate = CAST(cpl.FixedByChangesLastExecuted AS date)
	, FixedByChangesLastExecutedTime = CAST(cpl.FixedByChangesLastExecuted AS time(0))
	-- De volgende lijst kan maximaal uit 1024 tekens (zo'n 90 wijzigingen) bestaan, omdat dit het gekozen datatype in Fact.Problem is
	, FixedByChanges = CAST(STUFF((
		SELECT ', ' + CAST(c.number AS nvarchar(max))
		FROM [$(OGDW_Archive)].TOPdesk.change c
		INNER JOIN [$(OGDW_Archive)].TOPdesk.change_problem_link l ON l.changeid = c.unid AND c.SourceDatabaseKey = l.SourceDatabaseKey
		WHERE l.problemid = p.unid
		ORDER BY c.finaldate
		FOR XML PATH('')
		), 1, 2, '' ) AS nvarchar(1024))
	, ObjectsImpactedCnt = COALESCE(opl.ObjectsImpactedCnt, 0)
	-- De volgende lijst kan maximaal uit 1024 tekens bestaan, omdat dit het gekozen datatype in Fact.Problem is
	, ObjectsImpacted = CAST(STUFF((
		SELECT ', ' + CAST(o.ref_naam AS nvarchar(max))
		FROM [$(OGDW_Archive)].TOPdesk.[object] o
		INNER JOIN [$(OGDW_Archive)].TOPdesk.obj_problem_link l ON l.objectid = o.unid AND o.SourceDatabaseKey = l.SourceDatabaseKey
		WHERE l.problemid = p.unid
		ORDER BY o.ref_naam
		FOR XML PATH('')
		), 1, 2, '' ) AS nvarchar(1024))
FROM
	[$(OGDW_Archive)].TOPdesk.probleem p
	LEFT OUTER JOIN [$(OGDW_Archive)].TOPdesk.vrijeopzoekvelden v ON p.SourceDatabaseKey = v.SourceDatabaseKey AND p.vrijeopzoek1 = v.unid AND p.SourceDatabaseKey IN (40,342)
	LEFT OUTER JOIN ctePil pil ON pil.unid = p.unid AND pil.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN cteCpc cpc ON cpc.unid = p.unid AND cpc.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN cteCpl cpl ON cpl.unid = p.unid AND cpl.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN cteOpl opl ON opl.unid = p.unid AND opl.SourceDatabaseKey = p.SourceDatabaseKey
)

INSERT INTO
	[$(OGDW)].Fact.Problem
	(
	SourceDatabaseKey
	, AuditDWKey
	, CustomerKey
	, OperatorGroupKey
	, OperatorKey
	, ChangeDate
	, ChangeTime
	, KnownErrorDate
	, KnownErrorTime
	, ProblemDate
	, ProblemTime
	, CardCreatedBy
	, Closed
	, ClosedKownError
	, ClosedProblem
	, EstimatedTimeSpent
	, EstimatedCosts
	, TimeSpent
	, TimespentKnownError
	, TimespentProblem
	, CategoryKnownError
	, CategoryProblem
	, CreationDate
	, CreationTime
	, ClosureDate
	, ClosureTime
	, ClosureDateKnownError
	, ClosureTimeKnownError
	, ClosureDateProblem
	, ClosureTimeProblem
	, CompletionDate
	, CompletionTime
	, CompletionDateKnownError
	, CompletionTimeKnownError
	, CompletionDateProblem
	, CompletionTimeProblem
	, DurationKnownError
	, DurationProblem
	, ActualTimeSpent
	, DurationActual
	, DurationActualKnownError
	, DurationActualProblem
	, ActualCosts
	, Completed
	, CompletedKnownError
	, CompletedProblem
	, ImpactKnownError
	, Impact
	, [Type]
	, KnownErrorDescription
	, ProblemDescription
	, Manager
	, RemainingCosts
	, CostsKnownError
	, Costs
	, CostsProblem
	, ProblemCause
	, [Priority]
	, Problemnumber
	, ReasonArchiving
	, TimeRemaining
	, ProblemType
	, [Status]
	, StatusProcessFeedback
	, TargetDateKnownError
	, TargetTimeKnownError
	, TargetDate
	, TargetTime
	, SubcategoryKnownError
	, SubcategoryProblem
	, Urgency
	, CardChangedBy

	, IncidentsCnt
	, IncidentsFirstReportedDate
	, IncidentsFirstReportedTime
	, IncidentsLastReportedDate
	, IncidentsLastReportedTime
	, Incidents
	, CausedByChangesCnt
	, CausedByChangesFirstExecutedDate
	, CausedByChangesFirstExecutedTime
	, CausedByChangesLastExecutedDate
	, CausedByChangesLastExecutedTime
	, CausedByChanges
	, FixedByChangesCnt
	, FixedByChangesFirstExecutedDate
	, FixedByChangesFirstExecutedTime
	, FixedByChangesLastExecutedDate
	, FixedByChangesLastExecutedTime
	, FixedByChanges
	, ObjectsImpactedCnt
	, ObjectsImpacted
	)
SELECT
	PR.SourceDatabaseKey
	, PR.AuditDWKey

	-- Voor Multi-klant topdesk in de FileImport staat de Customer in de kolom [CustomerName], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Multi-klant topdesk in de database staat de Customer in [vestiging].[naam], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Single-klant topdesk in de FileImport is de kolom [CustomerName] = NULL en wordt de naam dus opgehaald via SourceDefinition
	-- Voor Single-klant topdesk in de database bevat de kolom [vestiging].[naam] daadwerkelijk de vestiging; halen we de Customer dus op via SourceDefinition
	-- Via onderstaande regel zou altijd een CustomerKey gevonden moeten worden, tenzij er geen vertaling gedefinieerd is
	, CustomerKey = ISNULL(CAST(CASE
			WHEN SD.MultipleCustomers = 0 THEN C1.Code -- Klantnaam via SourceDefinition
			ELSE ISNULL(C2.Code,-1) -- Klantnaam uit CustomerName veld, vertaald via SourceTranslation naar CustomerKey
		END AS int),-1) -- Bij gegevens uit de database moet deze key op een andere manier worden bepaald
	, OperatorGroupKey = ISNULL(PR.OperatorGroupKey,-1)
	, OperatorKey = ISNULL(PR.OperatorKey,-1)

	, PR.ChangeDate
	, PR.ChangeTime
	, PR.KnownErrorDate
	, PR.KnownErrorTime
	, PR.ProblemDate
	, PR.ProblemTime
	, PR.CardCreatedBy
	, PR.Closed
	, PR.ClosedKownError
	, PR.ClosedProblem
	, PR.EstimatedTimeSpent
	, PR.EstimatedCosts
	, PR.TimeSpent
	, PR.TimespentKnownError
	, PR.TimespentProblem
	, PR.CategoryKnownError
	, PR.CategoryProblem
	, PR.CreationDate
	, PR.CreationTime
	, PR.ClosureDate
	, PR.ClosureTime
	, PR.ClosureDateKnownError
	, PR.ClosureTimeKnownError
	, PR.ClosureDateProblem
	, PR.ClosureTimeProblem
	, PR.CompletionDate
	, PR.CompletionTime
	, PR.CompletionDateKnownError
	, PR.CompletionTimeKnownError
	, PR.CompletionDateProblem
	, PR.CompletionTimeProblem
	, PR.DurationKnownError
	, PR.DurationProblem
	, PR.ActualTimeSpent
	, PR.DurationActual
	, PR.DurationActualKnownError
	, PR.DurationActualProblem
	, PR.ActualCosts
	, PR.Completed
	, PR.CompletedKnownError
	, PR.CompletedProblem
	, PR.ImpactKnownError
	, PR.Impact
	, PR.[Type]
	, PR.KnownErrorDescription
	, PR.ProblemDescription
	, PR.Manager
	, PR.RemainingCosts
	, PR.CostsKnownError
	, PR.Costs
	, PR.CostsProblem
	, PR.ProblemCause
	, PR.[Priority]
	, PR.Problemnumber
	, PR.ReasonArchiving
	, PR.TimeRemaining
	, PR.ProblemType
	, PR.[Status]
	, PR.StatusProcessFeedback
	, PR.TargetDateKnownError
	, PR.TargetTimeKnownError
	, PR.TargetDate
	, PR.TargetTime
	, PR.SubcategoryKnownError
	, PR.SubcategoryProblem
	, PR.Urgency
	, PR.CardChangedBy

	, cteProblems.IncidentsCnt
	, cteProblems.IncidentsFirstReportedDate
	, cteProblems.IncidentsFirstReportedTime
	, cteProblems.IncidentsLastReportedDate
	, cteProblems.IncidentsLastReportedTime
	, cteProblems.Incidents
	, cteProblems.CausedByChangesCnt
	, cteProblems.CausedByChangesFirstExecutedDate
	, cteProblems.CausedByChangesFirstExecutedTime
	, cteProblems.CausedByChangesLastExecutedDate
	, cteProblems.CausedByChangesLastExecutedTime
	, cteProblems.CausedByChanges
	, cteProblems.FixedByChangesCnt
	, cteProblems.FixedByChangesFirstExecutedDate
	, cteProblems.FixedByChangesFirstExecutedTime
	, cteProblems.FixedByChangesLastExecutedDate
	, cteProblems.FixedByChangesLastExecutedTime
	, cteProblems.FixedByChanges
	, cteProblems.ObjectsImpactedCnt
	, cteProblems.ObjectsImpacted
FROM
	etl.Translated_Problem PR
	LEFT OUTER JOIN setup.SourceDefinition SD ON PR.SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.DimCustomer C1 ON SD.DatabaseLabel = C1.[Name]

--	Extra informatie per probleem mbt gekoppelde incidenten, wijzigingen etc
	LEFT OUTER JOIN cteProblems ON PR.Problemnumber = cteProblems.naam AND PR.SourceDatabaseKey = cteProblems.SourceDatabaseKey

	LEFT OUTER JOIN setup.SourceTranslation ST ON cteProblems.CustomerName = ST.SourceValue AND SD.DatabaseLabel = ST.SourceName
		AND ST.DWColumnName = 'CustomerName' AND TranslatedColumnName = 'CustomerAbbreviation'
	LEFT OUTER JOIN setup.DimCustomer C2 ON ST.TranslatedValue = C2.[Name]

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