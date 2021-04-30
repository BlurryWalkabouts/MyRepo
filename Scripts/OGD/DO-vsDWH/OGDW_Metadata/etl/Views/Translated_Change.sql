CREATE VIEW [etl].[Translated_Change]
AS
SELECT
	SourceDatabaseKey = T.SourceDatabaseKey
	, AuditDWKey
	, CallerKey =
			-- Deze query is exact hetzelfde in Translated_Incident en -Change. Wellicht kan hier ook een sproc of functie van gemaakt worden.
			(
			-- Er zou sowieso maar één CallerKey als resultaat terug mogen komen; TOP 1 is een extra check
			SELECT TOP 1
				CallerKey
			FROM
				[$(OGDW)].Dim.[Caller] c
			WHERE 1=1
				-- Zoek de juiste CallerKey op basis van SourceDatabaseKey en CallerName...
				AND T.SourceDatabaseKey = c.SourceDatabaseKey AND T.CallerName = c.CallerName
				AND
				(
				-- ...als het record niet bij de uitzonderingen hoort zoals gedefinieerd in het volgende blok
					(NOT T.SourceDatabaseKey IN (9,21,40,343,344)
				AND NOT T.SourceDatabaseKey IN (42,43)
				AND NOT (T.SourceDatabaseKey =  10 AND T.CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick'))
				AND NOT (T.SourceDatabaseKey = 323 AND T.CallerName IN ('Extern Aalsmeer,') AND T.CallerEmail <> '[Onbekend]')
				AND NOT (T.SourceDatabaseKey = 324 AND T.CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick'))
				AND NOT (T.SourceDatabaseKey = 323 AND T.CallerName IN ('Extern Aalsmeer,') AND T.CallerEmail = '[Onbekend]'))

				-- In die gevallen komt er namelijk nog een extra zoekwaarde bij. Deze uitzonderingen worden nader beschreven in Point_Caller.
				-- ...namelijk CallerBranch...
				OR (T.SourceDatabaseKey IN (9,21,40,343,344) AND T.CallerBranch = c.CallerBranch)
				-- ...of (Caller)Department...
				OR (T.SourceDatabaseKey IN (42,43) AND T.CallerDepartment = c.Department)
				-- ...of CallerEmail...
				OR (T.SourceDatabaseKey =  10 AND T.CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick') AND T.CallerEmail = c.CallerEmail)
				OR (T.SourceDatabaseKey = 323 AND T.CallerName IN ('Extern Aalsmeer,') AND T.CallerEmail <> '[Onbekend]' AND T.CallerEmail = c.CallerEmail)
				OR (T.SourceDatabaseKey = 324 AND T.CallerName IN ('Aanmelder, Onbekend','Test Tools, Rick') AND T.CallerEmail = c.CallerEmail)
				-- ...of CallerTelephoneNumber
				OR (T.SourceDatabaseKey = 323 AND T.CallerName IN ('Extern Aalsmeer,') AND T.CallerEmail = '[Onbekend]' AND T.CallerTelephoneNumber = c.CallerTelephoneNumber)
				)
			)
	, OperatorGroupKey = CASE SD.SourceType
			WHEN 'FILE' THEN og1.OperatorGroupKey
			WHEN 'ExcelToDB' THEN og1.OperatorGroupKey
			WHEN 'MSSQL' THEN og2.OperatorGroupKey
			WHEN 'XML' THEN og2.OperatorGroupKey
			ELSE -1
		END
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
	, ChangeType = CASE SD.SourceType
			WHEN 'FILE' THEN ChangeType
			WHEN 'ExcelToDB' THEN ChangeType
			WHEN 'MSSQL' THEN #ChangeType
			WHEN 'XML' THEN #ChangeType
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
	, Coordinator
	, CreationDate
	, CreationTime
	, CurrentPhase
	, CurrentPhaseSTD = CASE SD.SourceType
			WHEN 'FILE' THEN CurrentPhaseSTD
			WHEN 'ExcelToDB' THEN CurrentPhaseSTD
			WHEN 'MSSQL' THEN #CurrentPhaseSTD
			WHEN 'XML' THEN #CurrentPhaseSTD
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
	, DateCalcTypeEvaluation = CASE SD.SourceType
			WHEN 'FILE' THEN DateCalcTypeEvaluation
			WHEN 'ExcelToDB' THEN DateCalcTypeEvaluation
			WHEN 'MSSQL' THEN #DateCalcTypeEvaluation
			WHEN 'XML' THEN #DateCalcTypeEvaluation
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
	, DateCalcTypeProgress = CASE SD.SourceType
			WHEN 'FILE' THEN DateCalcTypeProgress
			WHEN 'ExcelToDB' THEN DateCalcTypeProgress
			WHEN 'MSSQL' THEN #DateCalcTypeProgress
			WHEN 'XML' THEN #DateCalcTypeProgress
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
	, DateCalcTypeRequestChange = CASE SD.SourceType
			WHEN 'FILE' THEN DateCalcTypeRequestChange
			WHEN 'ExcelToDB' THEN DateCalcTypeRequestChange
			WHEN 'MSSQL' THEN #DateCalcTypeRequestChange
			WHEN 'XML' THEN #DateCalcTypeRequestChange
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
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
FROM
	etl.Translation_step1_Change T
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = T.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og1 ON T.OperatorGroup = og1.OperatorGroup AND T.SourceDatabaseKey = og1.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og2 ON T.OperatorGroupID = og2.OperatorGroupID AND T.SourceDatabaseKey = og2.SourceDatabaseKey