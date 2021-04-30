CREATE VIEW [etl].[Translated_Problem]
AS
SELECT
	SourceDatabaseKey = T.SourceDatabaseKey
	, AuditDWKey
	, OperatorGroupKey = CASE SD.SourceType
			WHEN 'FILE' THEN og1.OperatorGroupKey
			WHEN 'ExcelToDB' THEN og1.OperatorGroupKey
			WHEN 'MSSQL' THEN og2.OperatorGroupKey
			WHEN 'XML' THEN og2.OperatorGroupKey
			ELSE -1
		END
	, OperatorKey = CASE SD.SourceType
			WHEN 'FILE' THEN NULL
			WHEN 'ExcelToDB' THEN NULL
			WHEN 'MSSQL' THEN NULL
			WHEN 'XML' THEN NULL
			ELSE -1
		END
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
	, CompletionDate = CASE WHEN Completed = 1 THEN CompletionDate ELSE NULL END
	, CompletionTime = CASE WHEN Completed = 1 THEN CompletionTime ELSE NULL END
	, CompletionDateKnownError = CASE WHEN Completed = 1 THEN CompletionDate ELSE NULL END
	, CompletionTimeKnownError = CASE WHEN Completed = 1 THEN CompletionTime ELSE NULL END
	, CompletionDateProblem = CASE WHEN Completed = 1 THEN CompletionDate ELSE NULL END
	, CompletionTimeProblem = CASE WHEN Completed = 1 THEN CompletionTime ELSE NULL END
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
FROM
	etl.Translation_step1_Problem T
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = T.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og1 ON T.OperatorGroup = og1.OperatorGroup AND T.SourceDatabaseKey = og1.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og2 ON T.OperatorGroupID = og2.OperatorGroupID AND T.SourceDatabaseKey = og2.SourceDatabaseKey