create function TOPdesk.tvfProbleem(@SourceDatabaseKey int, @AuditDWKey int) 
returns table as return (
with gebruiker2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.gebruiker
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,gebruiker as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.gebruiker
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,probleem_doorlooptijd as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.probleem_doorlooptijd
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,probleem_doorlooptijd2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.probleem_doorlooptijd
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,probleem_impact2 as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.probleem_impact
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,probleem_impact as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.probleem_impact
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,actiedoor as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.actiedoor
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,problem_priority as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.problem_priority
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,probleem_oorzaak as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.probleem_oorzaak
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,probleem_categorie as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.probleem_categorie
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,archiefreden as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.archiefreden
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,probleem_status as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.probleem_status
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,vrijeopzoekvelden as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.vrijeopzoekvelden
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
,problem_urgency as ( 
	select *, row_number() over (partition by unid order by AuditDWKey desc) as RN from TOPdesk.problem_urgency
	where SourceDatabaseKey = @SourceDatabaseKey and AuditDWKey <= @AuditDWKey )
select probleem.AuditDWKey,  [probleem].[totalekosten] as [ActualCosts]
, [probleem].[totaletijd] as [ActualTimeSpent]
, [gebruiker2].[naam] as [CardChangedBy]
, [gebruiker].[naam] as [CardCreatedBy]
, [probleem].[ref_domein] as [CategoryKnownError]
, [probleem].[ref_domeinprobleem] as [CategoryProblem]
, [probleem].[datwijzig] as [ChangeDate]
, [probleem].[refcombi_afgemeld] as [Closed]
, [probleem].[afgemeldbf] as [ClosedKownError]
, [probleem].[afgemeld] as [ClosedProblem]
, [probleem].[refcombi_datumafgemeld] as [ClosureDate]
, [probleem].[datumafgemeldbf] as [ClosureDateKnownError]
, [probleem].[datumafgemeld] as [ClosureDateProblem]
, [probleem].[refcombi_gereed] as [Completed]
, [probleem].[gereedbf] as [CompletedKnownError]
, [probleem].[gereed] as [CompletedProblem]
, [probleem].[refcombi_datumgereed] as [CompletionDate]
, [probleem].[datumgereedbf] as [CompletionDateKnownError]
, [probleem].[datumgereed] as [CompletionDateProblem]
, [probleem].[onkosten] as [Costs]
, [probleem].[onkostenbf] as [CostsKnownError]
, [probleem].[onkosten] as [CostsProblem]
, [probleem].[dataanmk] as [CreationDate]
, [probleem].[refcombi_minutendoorlooptijd] as [DurationActual]
, [probleem].[minutendoorlooptijdbf] as [DurationActualKnownError]
, [probleem].[minutendoorlooptijd] as [DurationActualProblem]
, [probleem_doorlooptijd].[naam] as [DurationKnownError]
, [probleem_doorlooptijd2].[naam] as [DurationProblem]
, [probleem].[kostenbegroot] as [EstimatedCosts]
, [probleem].[tijdbegroot] as [EstimatedTimeSpent]
, [probleem_impact2].[naam] as [Impact]
, [probleem_impact].[naam] as [ImpactKnownError]
, [probleem].[aanmaakdatumbf] as [KnownErrorDate]
, [probleem].[korteomschrijvingbf] as [KnownErrorDescription]
, [probleem].[refcombi_beheerder] as [Manager]
, [actiedoor].[ref_dynanaam] as [OperatorGroup]
, [probleem].[ref_behandelaar] as [OperatorName]
, [problem_priority].[naam] as [Priority]
, [probleem_oorzaak].[naam] as [ProblemCause]
, [probleem].[aanmaakdatum] as [ProblemDate]
, [probleem].[refcombi_korteomschrijving] as [ProblemDescription]
, [probleem].[naam] as [Problemnumber]
, [probleem_categorie].[naam] as [ProblemType]
, [archiefreden].[naam] as [ReasonArchiving]
, [probleem].[kostenverwacht] as [RemainingCosts]
, [probleem_status].[naam] as [Status]
, [vrijeopzoekvelden].[naam] as [StatusProcessFeedback]
, [probleem].[ref_specificatie] as [SubcategoryKnownError]
, [probleem].[ref_specificatieprobleem] as [SubcategoryProblem]
, [probleem].[streefdatum] as [TargetDate]
, [probleem].[streefdatumbf] as [TargetDateKnownError]
, [probleem].[tijdverwacht] as [TimeRemaining]
, [probleem].[refcombi_tijdbesteed] as [TimeSpent]
, [probleem].[tijdbesteedbf] as [TimespentKnownError]
, [probleem].[tijdbesteed] as [TimespentProblem]
, [probleem].[status] as [Type]
, [problem_urgency].[naam] as [Urgency]

 from TOPdesk.probleem
left join gebruiker2 on gebruiker2.unid = probleem.uidwijzig and gebruiker2.SourceDatabaseKey = probleem.SourceDatabaseKey
 and gebruiker2.RN = 1
left join gebruiker on gebruiker.unid = probleem.uidaanmk and gebruiker.SourceDatabaseKey = probleem.SourceDatabaseKey
 and gebruiker.RN = 1
left join probleem_doorlooptijd on probleem_doorlooptijd.unid = probleem.doorlooptijdbfid and probleem_doorlooptijd.SourceDatabaseKey = probleem.SourceDatabaseKey
 and probleem_doorlooptijd.RN = 1
left join probleem_doorlooptijd2 on probleem_doorlooptijd2.unid = probleem.doorlooptijdid and probleem_doorlooptijd2.SourceDatabaseKey = probleem.SourceDatabaseKey
 and probleem_doorlooptijd2.RN = 1
left join probleem_impact2 on probleem_impact2.unid = probleem.impactid and probleem_impact2.SourceDatabaseKey = probleem.SourceDatabaseKey
 and probleem_impact2.RN = 1
left join probleem_impact on probleem_impact.unid = probleem.impactbfid and probleem_impact.SourceDatabaseKey = probleem.SourceDatabaseKey
 and probleem_impact.RN = 1
left join actiedoor on actiedoor.unid = probleem.operatorgroupid and actiedoor.SourceDatabaseKey = probleem.SourceDatabaseKey
 and actiedoor.RN = 1
left join problem_priority on problem_priority.unid = probleem.priorityid and problem_priority.SourceDatabaseKey = probleem.SourceDatabaseKey
 and problem_priority.RN = 1
left join probleem_oorzaak on probleem_oorzaak.unid = probleem.oorzaakid and probleem_oorzaak.SourceDatabaseKey = probleem.SourceDatabaseKey
 and probleem_oorzaak.RN = 1
left join probleem_categorie on probleem_categorie.unid = probleem.categorieid and probleem_categorie.SourceDatabaseKey = probleem.SourceDatabaseKey
 and probleem_categorie.RN = 1
left join archiefreden on archiefreden.unid = probleem.archiefredenid and archiefreden.SourceDatabaseKey = probleem.SourceDatabaseKey
 and archiefreden.RN = 1
left join probleem_status on probleem_status.unid = probleem.statusid and probleem_status.SourceDatabaseKey = probleem.SourceDatabaseKey
 and probleem_status.RN = 1
left join vrijeopzoekvelden on vrijeopzoekvelden.unid = probleem.vrijeopzoek1 and vrijeopzoekvelden.SourceDatabaseKey = probleem.SourceDatabaseKey
 and vrijeopzoekvelden.RN = 1
left join problem_urgency on problem_urgency.unid = probleem.urgencyid and problem_urgency.SourceDatabaseKey = probleem.SourceDatabaseKey
 and problem_urgency.RN = 1

where probleem.AuditDWKey = @AuditDWKey
)