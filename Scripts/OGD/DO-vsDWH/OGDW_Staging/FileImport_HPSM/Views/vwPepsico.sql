CREATE VIEW [FileImport_HPSM].[vwPepsico]
AS
SELECT
	CustomerName = NULL
	, OperatorName = [Owner Contact Name (Interaction)]
	, TargetDate = NULL
	, NumberOfDaysCurrent = NULL
	, CompletionDate = CASE WHEN [Close Date GMT (Interaction)] > '21991231' THEN NULL ELSE [Close Date GMT (Interaction)] END
	, SlaTargetDate = NULL
	, SlaAchieved = NULL
	, StandardSolution = [Solution ID (Interaction)]
	, DurationAdjusted = [$(OGDW)].dbo.TimeSpan ([Open Date GMT (Interaction)], CASE WHEN [Close Date GMT (Interaction)] > '21991231' THEN NULL ELSE [Close Date GMT (Interaction)] END, 1)
	, CardCreatedBy = NULL
	, CallerBranch = [Market Name (Reported By)]
	, Department = NULL
	, Closed = CASE WHEN [Close Date GMT (Interaction)] != '4000-01-01 00:00:00.000' THEN '1' ELSE '0' END
	, TimeSpentFirstLine = CASE WHEN [First Level Resolution Indicator (Interaction)] = 1 THEN [$(OGDW)].dbo.TimeSpan ([Open Date GMT (Interaction)], CASE WHEN [Close Date GMT (Interaction)] > '21991231' THEN NULL ELSE [Close Date GMT (Interaction)] END, 1) ELSE '' END
	, TimeSpentSecondLine = NULL
	, Category = [Interaction Type (Interaction)]
	, ConfigurationID = NULL
	, OnHoldDate = NULL
	, CreationDate = [Open Date GMT (Interaction)]
	, ChangeDate = NULL
	, ClosureDate = [Close Date GMT (Interaction)]
	, Line = CASE WHEN [Escalated Indicator (Interaction)] = 1 THEN 'Tweedelijns' ELSE 'Eerstelijns' END
	, Duration = [$(OGDW)].dbo.TimeSpan ([Open Date GMT (Interaction)], CASE WHEN [Close Date GMT (Interaction)] > '21991231' THEN NULL ELSE [Close Date GMT (Interaction)] END, 1)
	, DurationOnHold = NULL
	, CallerEmail = NULL
	, ExternalNumber = NULL
	, DurationActual = [$(OGDW)].dbo.TimeSpan ([Open Date GMT (Interaction)], CASE WHEN [Close Date GMT (Interaction)] > '21991231' THEN NULL ELSE [Close Date GMT (Interaction)] END, 1)
	, Completed = CASE WHEN [Close Date GMT (Interaction)] != '4000-01-01 00:00:00.000' THEN '1' ELSE '0' END
	, TotalTime = [$(OGDW)].dbo.TimeSpan ([Open Date GMT (Interaction)],case when [Close Date GMT (Interaction)] > '21991231' THEN NULL ELSE [Close Date GMT (Interaction)] END, 1)
	, CallerGender = '[Onbekend]'
	, Impact = 'Middel'
	, IncidentNumber = [Interaction ID (Interaction)]
	, IsMajorIncident = '0'
	, IncidentDescription = [Title (Interaction)]
	, Supplier = NULL
	, MajorIncident = NULL
	, CallerMobileNumber = NULL
	, ObjectID = NULL
	, Onhold = NULL
	, CallerCity = NULL
	, [Priority] = [Priority (Interaction)]
	, ServiceWindow = NULL
	, IncidentDate = [Open Date GMT (Interaction)]
	, Sla = NULL
	, SlaContract = NULL
	, SlaLevel = NULL
	, EntryType = [Source (Interaction)]
	, Subcategory = NULL
	, CallerTelephoneNumber = NULL
	, CardChangedBy = NULL
	, CallerName = NULL
	, IncidentType = [Interaction Type (Interaction)]
	, [Status] = [Status (Interaction)]
	, OperatorGroup = [Group Name (Owner Group)]
FROM
	FileImport_HPSM.[Pepsico|Meldingen(Pepsico)]