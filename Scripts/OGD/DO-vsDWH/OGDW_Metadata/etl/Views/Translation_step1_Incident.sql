CREATE VIEW [etl].[Translation_step1_Incident]
AS
SELECT
	I.SourceDatabaseKey
	, I.AuditDWKey
	, I.OperatorGroupID
	, I.OperatorGroup
	, I.DurationActual AS [DurationActual]
	, I.DurationAdjusted AS [DurationAdjusted]
	, I.Category AS [Category]
	, I.ConfigurationID AS [ConfigurationID]
	, I.CardChangedBy AS [CardChangedBy]
	, CAST(I.ChangeDate AS date) AS [ChangeDate]
	, CAST(I.ChangeDate AS time(0)) AS [ChangeTime]
	, CAST(I.ClosureDate AS date) AS [ClosureDate]
	, CAST(I.ClosureDate AS time(0)) AS [ClosureTime]
	, I.Closed AS [Closed]
	, CAST(I.CompletionDate AS date) AS [CompletionDate]
	, CAST(I.CompletionDate AS time(0)) AS [CompletionTime]
	, I.Completed AS [Completed]
	, I.CardCreatedBy AS [CardCreatedBy]
	, CAST(I.CreationDate AS date) AS [CreationDate]
	, CAST(I.CreationDate AS time(0)) AS [CreationTime]
	, I.CustomerName AS [CustomerName]
	, COALESCE(T00.TranslatedValue, TD00.TranslatedValue, '[Onbekend]') AS CustomerAbbreviation
	, I.IncidentDescription AS [IncidentDescription]
	, I.DurationOnHold AS [DurationOnHold]
	, I.Duration AS [Duration]
	, I.EntryType AS [EntryType]
	, COALESCE(T01.TranslatedValue, TD01.TranslatedValue, '[Onbekend]') AS EntryTypeSTD
	, I.ExternalNumber AS [ExternalNumber]
	, I.Onhold AS [OnHold]
	, I.IsMajorIncident AS [IsMajorIncident]
	, I.Impact AS [Impact]
	, CAST(I.IncidentDate AS date) AS [IncidentDate]
	, CAST(I.IncidentDate AS time(0)) AS [IncidentTime]
	, I.Line AS [Line]
	, COALESCE(T02.TranslatedValue, TD02.TranslatedValue, '[Onbekend]') AS #Line
	, I.MajorIncident AS [MajorIncident]
	, I.IncidentNumber AS [IncidentNumber]
	, CAST(I.OnHoldDate AS date) AS [OnHoldDate]
	, CAST(I.OnHoldDate AS time(0)) AS [OnHoldTime]
	, I.ObjectID AS [ObjectID]
	, I.[Priority] AS [Priority]
	, COALESCE(T03.TranslatedValue, TD03.TranslatedValue, '[Onbekend]') AS PrioritySTD
	, I.Sla AS [Sla]
	, I.SlaContract AS [SlaContract]
	, I.SlaAchieved AS [SlaAchieved]
	, COALESCE(T06.TranslatedValue, TD06.TranslatedValue, '[Onbekend]') AS #SlaAchieved
	--, I.SlaLevel AS [SlaLevel] --Wouter: Deze doet het sinds 19-3 niet meer, staat in DWColumnDefs op import = 0, weet niet of dat klopt maar voor nu haal ik hem hier weg om te kijken of Staging to AM dan weer werkt.
	, I.StandardSolution AS [StandardSolution]
	, I.[Status] AS [Status]
	, COALESCE(T04.TranslatedValue, TD04.TranslatedValue, '[Onbekend]') AS StatusSTD
	, CAST(I.SlaTargetDate AS date) AS [SlaTargetDate]
	, CAST(I.SlaTargetDate AS time(0)) AS [SlaTargetTime]
	, I.Subcategory AS [Subcategory]
	, I.Supplier AS [Supplier]
	, I.ServiceWindow AS [ServiceWindow]
	, CAST(I.TargetDate AS date) AS [TargetDate]
	, CAST(I.TargetDate AS time(0)) AS [TargetTime]
	, I.TimeSpentFirstLine AS [TimeSpentFirstLine]
	, I.TotalTime AS [TotalTime]
	, I.TimeSpentSecondLine AS [TimeSpentSecondLine]
	, I.IncidentType AS [IncidentType]
	, COALESCE(T05.TranslatedValue, TD05.TranslatedValue, '[Onbekend]') AS IncidentTypeSTD
	, CallerName
	, CallerEmail = COALESCE(dbo.FormatEmailAddress(CallerEmail), '[Onbekend]')
	, CallerTelephoneNumber = COALESCE(dbo.FormatPhoneNumber(CallerTelephoneNumber), '[Onbekend]')
	, CallerDepartment = COALESCE(CallerDepartment, '[Onbekend]')
	, CallerBranch = COALESCE(CallerBranch, '[Onbekend]')
FROM
	etl.Current_Incident I
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = I.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceTranslation T00 ON T00.SourceName = SD.DatabaseLabel 
		AND T00.AMAnchorName = 'Incident'
		AND T00.DWColumnName = 'CustomerName'
		AND ISNULL(T00.SourceValue,-1) = ISNULL(CAST(I.CustomerName AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD00 ON TD00.SourceName = 'DEFAULT'
		AND TD00.AMAnchorName = 'Incident'
		AND TD00.DWColumnName = 'CustomerName'
		AND ISNULL(TD00.SourceValue,-1) = ISNULL(CAST(I.CustomerName AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T01 ON T01.SourceName = SD.DatabaseLabel 
		AND T01.AMAnchorName = 'Incident'
		AND T01.DWColumnName = 'EntryType'
		AND ISNULL(T01.SourceValue,-1) = ISNULL(CAST(I.EntryType AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD01 ON TD01.SourceName = 'DEFAULT'
		AND TD01.AMAnchorName = 'Incident'
		AND TD01.DWColumnName = 'EntryType'
		AND ISNULL(TD01.SourceValue,-1) = ISNULL(CAST(I.EntryType AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T02 ON T02.SourceName = SD.DatabaseLabel 
		AND T02.AMAnchorName = 'Incident'
		AND T02.DWColumnName = 'LineID'
		AND ISNULL(T02.SourceValue,-1) = ISNULL(CAST(I.LineID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD02 ON TD02.SourceName = 'DEFAULT'
		AND TD02.AMAnchorName = 'Incident'
		AND TD02.DWColumnName = 'LineID'
		AND ISNULL(TD02.SourceValue,-1) = ISNULL(CAST(I.LineID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T03 ON T03.SourceName = SD.DatabaseLabel 
		AND T03.AMAnchorName = 'Incident'
		AND T03.DWColumnName = 'Priority'
		AND ISNULL(T03.SourceValue,-1) = ISNULL(CAST(I.[Priority] AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD03 ON TD03.SourceName = 'DEFAULT'
		AND TD03.AMAnchorName = 'Incident'
		AND TD03.DWColumnName = 'Priority'
		AND ISNULL(TD03.SourceValue,-1) = ISNULL(CAST(I.[Priority] AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T04 ON T04.SourceName = SD.DatabaseLabel 
		AND T04.AMAnchorName = 'Incident'
		AND T04.DWColumnName = 'Status'
		AND ISNULL(T04.SourceValue,-1) = ISNULL(CAST(I.[Status] AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD04 ON TD04.SourceName = 'DEFAULT'
		AND TD04.AMAnchorName = 'Incident'
		AND TD04.DWColumnName = 'Status'
		AND ISNULL(TD04.SourceValue,-1) = ISNULL(CAST(I.[Status] AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T05 ON T05.SourceName = SD.DatabaseLabel 
		AND T05.AMAnchorName = 'Incident'
		AND T05.DWColumnName = 'IncidentType'
		AND ISNULL(T05.SourceValue,-1) = ISNULL(CAST(I.IncidentType AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD05 ON TD05.SourceName = 'DEFAULT'
		AND TD05.AMAnchorName = 'Incident'
		AND TD05.DWColumnName = 'IncidentType'
		AND ISNULL(TD05.SourceValue,-1) = ISNULL(CAST(I.IncidentType AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T06 ON T06.SourceName = SD.DatabaseLabel 
		AND T06.AMAnchorName = 'Incident'
		AND T06.DWColumnName = 'SlaAchievedID'
		AND ISNULL(T06.SourceValue,-1) = ISNULL(CAST(I.SlaAchievedID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD06 ON TD06.SourceName = 'DEFAULT'
		AND TD06.AMAnchorName = 'Incident'
		AND TD06.DWColumnName = 'SlaAchievedID'
		AND ISNULL(TD06.SourceValue,-1) = ISNULL(CAST(I.SlaAchievedID AS varchar(max)),'-1')