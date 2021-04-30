CREATE VIEW [etl].[Translated_ChangeActivity]
AS
SELECT
	ChangeActivityID

	, SourceDatabaseKey = T.SourceDatabaseKey
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

	, ActivityNumber
	, BriefDescription
	, Category
	, Subcategory
	, [Status]
	, ProcessingStatus
	, ActivityTemplate

	, ActivityChange
	, ChangeBriefDescription
	, ChangePhase

	, CardCreatedBy
	, CreationDateTime
	, CreationDate
	, CreationTime
	, CardChangedBy
	, ChangeDateTime
	, ChangeDate
	, ChangeTime

	, MayStart
	, PlannedStartDateTime
	, PlannedStartDate
	, PlannedStartTime
	, PlannedFinalDateTime
	, PlannedFinalDate
	, PlannedFinalTime
	, Approved
	, ApprovedDateTime = CASE Approved WHEN 1 THEN ApprovedDateTime ELSE NULL END
	, ApprovedDate = CASE Approved WHEN 1 THEN ApprovedDate ELSE NULL END
	, ApprovedTime = CASE Approved WHEN 1 THEN ApprovedTime ELSE NULL END
	, Rejected
	, RejectedDateTime = CASE Rejected WHEN 1 THEN RejectedDateTime ELSE NULL END
	, RejectedDate = CASE Rejected WHEN 1 THEN RejectedDate ELSE NULL END
	, RejectedTime = CASE Rejected WHEN 1 THEN RejectedTime ELSE NULL END
	, [Started]
	, StartedDateTime = CASE [Started] WHEN 1 THEN StartedDateTime ELSE NULL END
	, StartedDate = CASE [Started] WHEN 1 THEN StartedDate ELSE NULL END
	, StartedTime = CASE [Started] WHEN 1 THEN StartedTime ELSE NULL END
	, Resolved
	, ResolvedDateTime = CASE Resolved WHEN 1 THEN ResolvedDateTime ELSE NULL END
	, ResolvedDate = CASE Resolved WHEN 1 THEN ResolvedDate ELSE NULL END
	, ResolvedTime = CASE Resolved WHEN 1 THEN ResolvedTime ELSE NULL END
	, Skipped
	, SkippedDateTime = CASE Skipped WHEN 1 THEN SkippedDateTime ELSE NULL END
	, SkippedDate = CASE Skipped WHEN 1 THEN SkippedDate ELSE NULL END
	, SkippedTime = CASE Skipped WHEN 1 THEN SkippedTime ELSE NULL END
	, Closed
	, ClosureDateTime = CASE Closed WHEN 1 THEN ClosureDateTime ELSE NULL END
	, ClosureDate = CASE Closed WHEN 1 THEN ClosureDate ELSE NULL END
	, ClosureTime = CASE Closed WHEN 1 THEN ClosureTime ELSE NULL END

	, CurrentPlanTimeTaken
	, OriginalPlanTimeTaken
	, TimeTaken

	, MaxPreviousActivityEndDate
	, ChangePhaseStartDate
	, [Level]
	, PlannedStartRank
FROM
	etl.Translation_step1_ChangeActivity T
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = T.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og1 ON T.OperatorGroup = og1.OperatorGroup AND T.SourceDatabaseKey = og1.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og2 ON T.OperatorGroupID = og2.OperatorGroupID AND T.SourceDatabaseKey = og2.SourceDatabaseKey