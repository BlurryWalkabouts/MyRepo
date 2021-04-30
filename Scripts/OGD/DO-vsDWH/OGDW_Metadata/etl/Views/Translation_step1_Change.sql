CREATE VIEW [etl].[Translation_step1_Change]
AS
SELECT
	I.SourceDatabaseKey
	, I.AuditDWKey
	, I.OperatorGroupID
	, I.OperatorGroup
	, I.Category AS [Category]
	, I.CardChangedBy AS [CardChangedBy]
	, CAST(I.ChangeDate AS date) AS [ChangeDate]
	, CAST(I.ChangeDate AS time(0)) AS [ChangeTime]
	, CAST(I.ClosureDateSimpleChange AS date) AS [ClosureDateSimpleChange]
	, CAST(I.ClosureDateSimpleChange AS time(0)) AS [ClosureTimeSimpleChange]
	, I.Closed AS [Closed]
	, I.CardCreatedBy AS [CardCreatedBy]
	, I.CustomerName AS [CustomerName]
	, I.ExternalNumber AS [ExternalNumber]
	, I.Impact AS [Impact]
	, I.ChangeNumber AS [ChangeNumber]
	, I.ObjectID AS [ObjectID]
	, I.[Priority] AS [Priority]
	, I.[Status] AS [Status]
	, I.Subcategory AS [Subcategory]
	, CAST(I.AuthorizationDate AS date) AS [AuthorizationDate]
	, CAST(I.AuthorizationDate AS time(0)) AS [AuthorizationTime]
	, CAST(I.CancelDateExtChange AS date) AS [CancelDateExtChange]
	, CAST(I.CancelDateExtChange AS time(0)) AS [CancelTimeExtChange]
	, I.CancelledByManager AS [CancelledByManager]
	, I.CancelledByOperator AS [CancelledByOperator]
	, I.ChangeType AS [ChangeType]
	, COALESCE(T00.TranslatedValue, TD00.TranslatedValue, '[Onbekend]') AS #ChangeType
	, I.Coordinator AS [Coordinator]
	, CAST(I.CreationDate AS date) AS [CreationDate], CAST(I.CreationDate AS time(0)) AS [CreationTime]
	, I.CurrentPhase AS [CurrentPhase]
	, COALESCE(T01.TranslatedValue, TD01.TranslatedValue, '[Onbekend]') AS CurrentPhaseSTD
	, COALESCE(T02.TranslatedValue, TD02.TranslatedValue, '[Onbekend]') AS #CurrentPhaseSTD
	, I.DateCalcTypeEvaluation AS [DateCalcTypeEvaluation]
	, COALESCE(T03.TranslatedValue, TD03.TranslatedValue, '[Onbekend]') AS #DateCalcTypeEvaluation
	, I.DateCalcTypeProgress AS [DateCalcTypeProgress]
	, COALESCE(T04.TranslatedValue, TD04.TranslatedValue, '[Onbekend]') AS #DateCalcTypeProgress
	, I.DateCalcTypeRequestChange AS [DateCalcTypeRequestChange]
	, COALESCE(T05.TranslatedValue, TD05.TranslatedValue, '[Onbekend]') AS #DateCalcTypeRequestChange
	, I.DescriptionBrief AS [DescriptionBrief]
	, CAST(I.EndDateExtChange AS date) AS [EndDateExtChange]
	, CAST(I.EndDateExtChange AS time(0)) AS [EndTimeExtChange]
	, I.Evaluation AS [Evaluation]
	, CAST(I.ImplDateExtChange AS date) AS [ImplDateExtChange]
	, CAST(I.ImplDateExtChange AS time(0)) AS [ImplTimeExtChange]
	, CAST(I.ImplDateSimpleChange AS date) AS [ImplDateSimpleChange]
	, CAST(I.ImplDateSimpleChange AS time(0)) AS [ImplTimeSimpleChange]
	, I.Implemented AS [Implemented]
--	, I.MajorIncidentId AS [MajorIncidentId]
	, CAST(I.NoGoDateExtChange AS date) AS [NoGoDateExtChange]
	, CAST(I.NoGoDateExtChange AS time(0)) AS [NoGoTimeExtChange]
	, I.OperatorEvaluationExtChange AS [OperatorEvaluationExtChange]
	, I.OperatorProgressExtChange AS [OperatorProgressExtChange]
	, I.OperatorRequestChange AS [OperatorRequestChange]
	, I.OperatorSimpleChange AS [OperatorSimpleChange]
	, I.OriginalIncident AS [OriginalIncident]
	, CAST(I.PlannedAuthDateRequestChange AS date) AS [PlannedAuthDateRequestChange]
	, CAST(I.PlannedAuthDateRequestChange AS time(0)) AS [PlannedAuthTimeRequestChange]
	, CAST(I.PlannedFinalDate AS date) AS [PlannedFinalDate]
	, CAST(I.PlannedFinalDate AS time(0)) AS [PlannedFinalTime]
	, CAST(I.PlannedImplDate AS date) AS [PlannedImplDate]
	, CAST(I.PlannedImplDate AS time(0)) AS [PlannedImplTime]
	, CAST(I.PlannedStartDateSimpleChange AS date) AS [PlannedStartDateSimpleChange]
	, CAST(I.PlannedStartDateSimpleChange AS time(0)) AS [PlannedStartTimeSimpleChange]
	, I.ProcessingStatus AS [ProcessingStatus]
	, I.Rejected AS [Rejected]
	, CAST(I.RejectionDate AS date) AS [RejectionDate]
	, CAST(I.RejectionDate AS time(0)) AS [RejectionTime]
	, CAST(I.RequestDate AS date) AS [RequestDate]
	, CAST(I.RequestDate AS time(0)) AS [RequestTime]
	, CAST(I.StartDateSimpleChange AS date) AS [StartDateSimpleChange]
	, CAST(I.StartDateSimpleChange AS time(0)) AS [StartTimeSimpleChange]
	, I.[Started] AS [Started]
	, CAST(I.SubmissionDateRequestChange AS date) AS [SubmissionDateRequestChange]
	, CAST(I.SubmissionDateRequestChange AS time(0)) AS [SubmissionTimeRequestChange]
	, I.Template AS [Template]
	, I.TimeSpent AS [TimeSpent]
	, I.[Type] AS [Type]
	, COALESCE(T06.TranslatedValue, TD06.TranslatedValue, '[Onbekend]') AS TypeSTD
	, I.Urgency AS [Urgency]
	, CallerName
	, CallerEmail = COALESCE(dbo.FormatEmailAddress(CallerEmail), '[Onbekend]')
	, CallerTelephoneNumber = COALESCE(dbo.FormatPhoneNumber(CallerTelephoneNumber), '[Onbekend]')
	, CallerDepartment = COALESCE(CallerDepartment, '[Onbekend]')
	, CallerBranch = COALESCE(CallerBranch, '[Onbekend]')
FROM
	etl.Current_Change I
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = I.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceTranslation T00 ON T00.SourceName = SD.DatabaseLabel 
		AND T00.AMAnchorName = 'Change'
		AND T00.DWColumnName = 'ChangeTypeID'
		AND ISNULL(T00.SourceValue,-1) = ISNULL(CAST(I.ChangeTypeID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD00 ON TD00.SourceName = 'DEFAULT'
		AND TD00.AMAnchorName = 'Change'
		AND TD00.DWColumnName = 'ChangeTypeID'
		AND ISNULL(TD00.SourceValue,-1) = ISNULL(CAST(I.ChangeTypeID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T01 ON T01.SourceName = SD.DatabaseLabel 
		AND T01.AMAnchorName = 'Change'
		AND T01.DWColumnName = 'CurrentPhase'
		AND ISNULL(T01.SourceValue,-1) = ISNULL(CAST(I.CurrentPhase AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD01 ON TD01.SourceName = 'DEFAULT'
		AND TD01.AMAnchorName = 'Change'
		AND TD01.DWColumnName = 'CurrentPhase'
		AND ISNULL(TD01.SourceValue,-1) = ISNULL(CAST(I.CurrentPhase AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T02 ON T02.SourceName = SD.DatabaseLabel 
		AND T02.AMAnchorName = 'Change'
		AND T02.DWColumnName = 'CurrentPhaseID'
		AND ISNULL(T02.SourceValue,-1) = ISNULL(CAST(I.CurrentPhaseID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD02 ON TD02.SourceName = 'DEFAULT'
		AND TD02.AMAnchorName = 'Change'
		AND TD02.DWColumnName = 'CurrentPhaseID'
		AND ISNULL(TD02.SourceValue,-1) = ISNULL(CAST(I.CurrentPhaseID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T03 ON T03.SourceName = SD.DatabaseLabel 
		AND T03.AMAnchorName = 'Change'
		AND T03.DWColumnName = 'DateCalcTypeEvaluationID'
		AND ISNULL(T03.SourceValue,-1) = ISNULL(CAST(I.DateCalcTypeEvaluationID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD03 ON TD03.SourceName = 'DEFAULT'
		AND TD03.AMAnchorName = 'Change'
		AND TD03.DWColumnName = 'DateCalcTypeEvaluationID'
		AND ISNULL(TD03.SourceValue,-1) = ISNULL(CAST(I.DateCalcTypeEvaluationID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T04 ON T04.SourceName = SD.DatabaseLabel 
		AND T04.AMAnchorName = 'Change'
		AND T04.DWColumnName = 'DateCalcTypeProgressID'
		AND ISNULL(T04.SourceValue,-1) = ISNULL(CAST(I.DateCalcTypeProgressID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD04 ON TD04.SourceName = 'DEFAULT'
		AND TD04.AMAnchorName = 'Change'
		AND TD04.DWColumnName = 'DateCalcTypeProgressID'
		AND ISNULL(TD04.SourceValue,-1) = ISNULL(CAST(I.DateCalcTypeProgressID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T05 ON T05.SourceName = SD.DatabaseLabel 
		AND T05.AMAnchorName = 'Change'
		AND T05.DWColumnName = 'DateCalcTypeRequestChangeID'
		AND ISNULL(T05.SourceValue,-1) = ISNULL(CAST(I.DateCalcTypeRequestChangeID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD05 ON TD05.SourceName = 'DEFAULT'
		AND TD05.AMAnchorName = 'Change'
		AND TD05.DWColumnName = 'DateCalcTypeRequestChangeID'
		AND ISNULL(TD05.SourceValue,-1) = ISNULL(CAST(I.DateCalcTypeRequestChangeID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T06 ON T06.SourceName = SD.DatabaseLabel 
		AND T06.AMAnchorName = 'Change'
		AND T06.DWColumnName = 'Type'
		AND ISNULL(T06.SourceValue,-1) = ISNULL(CAST(I.[Type] AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD06 ON TD06.SourceName = 'DEFAULT'
		AND TD06.AMAnchorName = 'Change'
		AND TD06.DWColumnName = 'Type'
		AND ISNULL(TD06.SourceValue,-1) = ISNULL(CAST(I.[Type] AS varchar(max)),'-1')