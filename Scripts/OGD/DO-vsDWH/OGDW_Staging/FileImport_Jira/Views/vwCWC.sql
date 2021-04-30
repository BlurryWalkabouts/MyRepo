CREATE VIEW [FileImport_Jira].[vwCWC]
AS
SELECT
	CallerBranch = 'Capelle aan den IJssel'
	, CallerCity = 'Capelle aan den IJssel'
	, CallerEmail = [Custom field (Email address)]
	, CallerGender = '[Onbekend]'
	, CallerMobileNumber = ''
	, CallerName = Reporter
	, CallerTelephoneNumber = [Custom field (Phone Number)]
	, CardChangedBy = Assignee
	, CardCreatedBy = Creator
	, Category = [Custom field (Category)]
	, ChangeDate = CONVERT(datetime, [Updated], 105)

	-- Voor SPAM meldingen ontbreekt vaak de [resolved] datum, in dat geval gebruiken we [updated] (anders word deze oa meegeteld als openstaand)
	, Closed = CASE WHEN [Resolved] IS NOT NULL THEN '1' WHEN [Status] = 'Spam melding' THEN '1'	ELSE '0'	END
	, ClosureDate = CASE WHEN [Resolved] IS NULL AND [Status] = 'Spam melding' THEN CONVERT(datetime, [Updated], 105) ELSE CONVERT(datetime, [Resolved], 105) END
	, Completed = CASE WHEN [Resolved] IS NOT NULL THEN '1' WHEN [Status] = 'Spam melding' THEN '1' ELSE '0' END
	, CompletionDate = CASE WHEN [Resolved] IS NULL AND [Status] = 'Spam melding' THEN CONVERT(datetime, [Updated], 105) ELSE CONVERT(datetime, [Resolved], 105) END

	, ConfigurationID = NULL
	, CreationDate = CONVERT(datetime, [Created], 105)
	, CustomerName = [Custom field (Customer)]
	, Department = NULL
	, Duration = NULL
	, DurationActual = [$(OGDW)].dbo.TimeSpan (CONVERT(datetime, [Created], 105), CONVERT(datetime, [Resolved], 105), 1)
	, DurationAdjusted = [$(OGDW)].dbo.TimeSpan (CONVERT(datetime, [Created], 105), CONVERT(datetime, [Resolved], 105), 1)
	, DurationOnHold = '0'
	, EntryType = 'Telefonisch'
	, ExternalNumber = NULL
	, Impact = 'Middel'
	, IncidentDate = CONVERT(datetime, [Created], 105)
	, IncidentDescription = [Summary]
	, IncidentNumber = [Issue key]
	, IncidentType = [Issue Type]
	, IsMajorIncident = '0'
	, Line = 'Tweedelijns melding'
	, MajorIncident = NULL
	, NumberOfDaysCurrent = NULL -- Berekenen we later aan de hand van start- en einddatum
	, ObjectID = NULL
	, Onhold = NULL
	, OnHoldDate = NULL
	, OperatorGroup = [Custom field (Assignee)]
	, OperatorName = Assignee
	, [Priority]
	, ServiceWindow = NULL
	, Sla = NULL
	, SlaAchieved = NULL
	, SlaContract = NULL
	, SlaLevel = 'Standaard'
	, StandardSolution = NULL -- Er is wel een veld [Solution], maar dit is geen standard-solution.
	, [Status]
	, Subcategory = NULL
	, Supplier = NULL
	, TargetDate = NULL
	, SlaTargetDate = NULL
	, TimeSpentFirstLine = NULL
	, TimeSpentSecondLine = NULL
	, TotalTime = NULL
	, AuditDWKey = NULL
FROM
	FileImport_Jira.[CWC|meldingen(cwc)]