-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_Problem viewed as it was ON the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [etl].[Point_Problem]
(
	@changingTimepoint datetime2(0)
)
RETURNS TABLE
AS
RETURN

SELECT
	SourceDatabaseKey = p.SourceDatabaseKey
	, AuditDWKey = p.AuditDWKey

	, OperatorID = p.actiedoorid
	, OperatorName = a1.ref_dynanaam
	, OperatorGroupID = p.operatorgroupid
	, OperatorGroup = a2.ref_dynanaam

	, Problemnumber = p.naam
	, CardCreatedBy = g1.naam
	, CardChangedBy = g2.naam
	, CreationDate= p.dataanmk
	, ChangeDate = p.datwijzig
	, CategoryProblem = c1.naam
	, CategoryKnownError = c2.naam
	, SubcategoryProblem = c3.naam
	, SubcategoryKnownError = c4.naam

	, [Type] = p.[status]
	, Urgency = pu.naam
	, [Priority] = pr.naam
	, ProblemCause = po.naam
	, ProblemType = pc.naam
	, ReasonArchiving = ar.naam
	, [Status] = ps.naam
	, StatusProcessFeedback = vv.naam

	, ProblemDescription = p.refcombi_korteomschrijving
--	, Date
	, Closed = p.refcombi_afgemeld
	, ClosureDate = p.refcombi_datumafgemeld
	, Completed = p.refcombi_gereed
	, CompletionDate = p.refcombi_datumgereed
	, Costs = p.onkosten -- = CostsProblem
	, DurationActual = p.refcombi_minutendoorlooptijd
--	, Duration
--	, Impact
--	, TargetDate
	, Manager = p.refcombi_beheerder
	, TimeSpent = p.refcombi_tijdbesteed

--	, ProblemDescription
	, ProblemDate = p.aanmaakdatum
	, ClosedProblem = p.afgemeld
	, ClosureDateProblem = p.datumafgemeld
	, CompletedProblem = p.gereed
	, CompletionDateProblem = p.datumgereed
	, CostsProblem = p.onkosten
	, DurationActualProblem = p.minutendoorlooptijd
	, DurationProblem = d1.naam
	, Impact = i1.naam
	, TargetDate = p.streefdatum
	, TimespentProblem = p.tijdbesteed

	, KnownErrorDescription = p.korteomschrijvingbf
	, KnownErrorDate = p.aanmaakdatumbf
	, ClosedKownError = p.afgemeldbf
	, ClosureDateKnownError = p.datumafgemeldbf
	, CompletedKnownError = p.gereedbf
	, CompletionDateKnownError = p.datumgereedbf
	, CostsKnownError = p.onkostenbf
	, DurationActualKnownError = p.minutendoorlooptijdbf
	, DurationKnownError = d2.naam
	, ImpactKnownError = i2.naam
	, TargetDateKnownError = p.streefdatumbf
	, TimespentKnownError = p.tijdbesteedbf

	, EstimatedCosts = p.kostenbegroot
	, ActualCosts = p.totalekosten
	, RemainingCosts = p.kostenverwacht

	, EstimatedTimeSpent = p.tijdbegroot
	, ActualTimeSpent = p.totaletijd
	, TimeRemaining = p.tijdverwacht
FROM
	TOPdesk.probleem FOR SYSTEM_TIME AS OF @changingTimepoint p
	LEFT OUTER JOIN TOPdesk.gebruiker             FOR SYSTEM_TIME AS OF @changingTimepoint g1 ON g1.unid = p.uidaanmk               AND g1.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.gebruiker             FOR SYSTEM_TIME AS OF @changingTimepoint g2 ON g2.unid = p.uidwijzig              AND g2.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.probleem_doorlooptijd FOR SYSTEM_TIME AS OF @changingTimepoint d1 ON d1.unid = p.doorlooptijdid         AND d1.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.probleem_doorlooptijd FOR SYSTEM_TIME AS OF @changingTimepoint d2 ON d2.unid = p.doorlooptijdbfid       AND d2.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.probleem_impact       FOR SYSTEM_TIME AS OF @changingTimepoint i1 ON i1.unid = p.impactid               AND i1.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.probleem_impact       FOR SYSTEM_TIME AS OF @changingTimepoint i2 ON i2.unid = p.impactbfid             AND i2.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie         FOR SYSTEM_TIME AS OF @changingTimepoint c1 ON c1.unid = p.domeinprobleemid       AND c1.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie         FOR SYSTEM_TIME AS OF @changingTimepoint c2 ON c2.unid = p.domeinid               AND c2.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie         FOR SYSTEM_TIME AS OF @changingTimepoint c3 ON c3.unid = p.specificatieprobleemid AND c3.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie         FOR SYSTEM_TIME AS OF @changingTimepoint c4 ON c4.unid = p.specificatieid         AND c4.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.actiedoor             FOR SYSTEM_TIME AS OF @changingTimepoint a1 ON a1.unid = p.actiedoorid            AND a1.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.actiedoor             FOR SYSTEM_TIME AS OF @changingTimepoint a2 ON a2.unid = p.operatorgroupid        AND a2.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.problem_priority      FOR SYSTEM_TIME AS OF @changingTimepoint pr ON pr.unid = p.priorityid             AND pr.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.probleem_oorzaak      FOR SYSTEM_TIME AS OF @changingTimepoint po ON po.unid = p.oorzaakid              AND po.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.probleem_categorie    FOR SYSTEM_TIME AS OF @changingTimepoint pc ON pc.unid = p.categorieid            AND pc.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.archiefreden          FOR SYSTEM_TIME AS OF @changingTimepoint ar ON ar.unid = p.archiefredenid         AND ar.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.probleem_status       FOR SYSTEM_TIME AS OF @changingTimepoint ps ON ps.unid = p.statusid               AND ps.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.vrijeopzoekvelden     FOR SYSTEM_TIME AS OF @changingTimepoint vv ON vv.unid = p.vrijeopzoek1           AND vv.SourceDatabaseKey = p.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.problem_urgency       FOR SYSTEM_TIME AS OF @changingTimepoint pu ON pu.unid = p.urgencyid              AND pu.SourceDatabaseKey = p.SourceDatabaseKey