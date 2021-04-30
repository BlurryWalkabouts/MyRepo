CREATE VIEW [etl].[Translated_Incident]
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
	, ObjectKey = o.ObjectKey

	, DurationActual
	, DurationAdjusted
	, Category
	, ConfigurationID
	, CardChangedBy
	, ChangeDate = T.ChangeDate
	, ChangeTime = T.ChangeTime
	, ClosureDate = CASE WHEN T.Closed = 1 THEN T.ClosureDate ELSE NULL END
	, ClosureTime = CASE WHEN T.Closed = 1 THEN T.ClosureTime ELSE NULL END
	, Closed
	, CompletionDate = CASE WHEN T.Completed = 1 THEN T.CompletionDate WHEN T.Completed = 0 AND T.Closed = 1 THEN T.ClosureDate ELSE NULL END
	, CompletionTime = CASE WHEN T.Completed = 1 THEN T.CompletionTime WHEN T.Completed = 0 AND T.Closed = 1 THEN T.ClosureTime ELSE NULL END
	, Completed = CASE WHEN T.Closed = 1 THEN 1 ELSE T.Completed END
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
	, Line = CASE SD.SourceType
			WHEN 'FILE' THEN Line
			WHEN 'ExcelToDB' THEN Line
			WHEN 'MSSQL' THEN #Line
			WHEN 'XML' THEN #Line
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
	, MajorIncident
	, IncidentNumber
	, OnHoldDate = CASE WHEN OnHold = 1 THEN OnHoldDate ELSE NULL END
	, OnHoldTime = CASE WHEN OnHold = 1 THEN OnHoldTime ELSE NULL END
	, ObjectID = T.ObjectID
	, [Priority]
	, PrioritySTD
	, Sla
	, SlaContract
	, StandardSolution
	, [Status] = T.[Status]
	, StatusSTD
	, SlaTargetDate
	, SlaTargetTime
	, Subcategory
	, Supplier = T.Supplier
	, ServiceWindow
	, TargetDate
	, TargetTime
	, TimeSpentFirstLine
	, TotalTime
	, TimeSpentSecondLine
	, IncidentType
	, IncidentTypeSTD
	, SlaAchieved = CASE SD.SourceType
			WHEN 'FILE' THEN SlaAchieved
			WHEN 'ExcelToDB' THEN SlaAchieved
			WHEN 'MSSQL' THEN #SlaAchieved
			WHEN 'XML' THEN #SlaAchieved
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
FROM
	etl.Translation_step1_Incident T
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = T.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og1 ON og1.OperatorGroup = T.OperatorGroup AND og1.SourceDatabaseKey = T.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.OperatorGroup og2 ON og2.OperatorGroupID = T.OperatorGroupID AND og2.SourceDatabaseKey = T.SourceDatabaseKey
	LEFT OUTER JOIN [$(OGDW)].Dim.[Object] o ON o.ObjectID = T.ObjectID AND o.SourceDatabaseKey = T.SourceDatabaseKey