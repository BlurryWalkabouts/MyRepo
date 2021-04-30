CREATE VIEW [etl].[Translation_step1_ChangeActivity]
AS
SELECT
	ChangeActivityID = ROW_NUMBER() OVER (ORDER BY I.SourceDatabaseKey)

	, SourceDatabaseKey
	, AuditDWKey

	, OperatorGroupID
	, OperatorGroup
	, OperatorID
	, OperatorName

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
	, CreationDateTime = CAST(CreationDate AS datetime)
	, CreationDate = CAST(CreationDate AS date)
	, CreationTime = CAST(CreationDate AS time(0))
	, CardChangedBy
	, ChangeDateTime = CAST(ChangeDate AS datetime)
	, ChangeDate = CAST(ChangeDate AS date)
	, ChangeTime = CAST(ChangeDate AS time(0))

	, MayStart
	, PlannedStartDateTime = CAST(PlannedStartDate AS datetime)
	, PlannedStartDate = CAST(PlannedStartDate AS date)
	, PlannedStartTime = CAST(PlannedStartDate AS time(0))
	, PlannedFinalDateTime = CAST(PlannedFinalDate AS datetime)
	, PlannedFinalDate = CAST(PlannedFinalDate AS date)
	, PlannedFinalTime = CAST(PlannedFinalDate AS time(0))
	, Approved
	, ApprovedDateTime = CAST(ApprovedDate AS datetime)
	, ApprovedDate = CAST(ApprovedDate AS date)
	, ApprovedTime = CAST(ApprovedDate AS time(0))
	, Rejected
	, RejectedDateTime = CAST(RejectedDate AS datetime)
	, RejectedDate = CAST(RejectedDate AS date)
	, RejectedTime = CAST(RejectedDate AS time(0))
	, [Started]
	, StartedDateTime = CAST(StartedDate AS datetime)
	, StartedDate = CAST(StartedDate AS date)
	, StartedTime = CAST(StartedDate AS time(0))
	, Resolved
	, ResolvedDateTime = CAST(ResolvedDate AS datetime)
	, ResolvedDate = CAST(ResolvedDate AS date)
	, ResolvedTime = CAST(ResolvedDate AS time(0))
	, Skipped
	, SkippedDateTime = CAST(SkippedDate AS datetime)
	, SkippedDate = CAST(SkippedDate AS date)
	, SkippedTime = CAST(SkippedDate AS time(0))
	, Closed = COALESCE(Rejected, Resolved, Skipped)
	, ClosureDateTime = CAST(COALESCE(RejectedDate, ResolvedDate, SkippedDate) AS datetime)
	, ClosureDate = CAST(COALESCE(RejectedDate, ResolvedDate, SkippedDate) AS date)
	, ClosureTime = CAST(COALESCE(RejectedDate, ResolvedDate, SkippedDate) AS time(0))

	, CurrentPlanTimeTaken
	, OriginalPlanTimeTaken
	, TimeTaken

	, MaxPreviousActivityEndDate
	, ChangePhaseStartDate
	, [Level]
	, PlannedStartRank
FROM
	etl.Current_ChangeActivity I
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = I.SourceDatabaseKey