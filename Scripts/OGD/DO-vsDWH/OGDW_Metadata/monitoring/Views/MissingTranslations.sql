CREATE VIEW [monitoring].[MissingTranslations]
AS

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'OperatorGroup'
	, [Missende waarde] = O.OperatorGroup
FROM
	[$(OGDW)].Fact.Incident I
	INNER JOIN [$(OGDW)].Dim.OperatorGroup O ON I.SourceDatabaseKey = O.SourceDatabaseKey AND I.OperatorGroupKey = O.OperatorGroupKey
	INNER JOIN setup.SourceDefinition SD ON I.SourceDatabaseKey = SD.Code
WHERE 1=1
	AND O.OperatorGroupSTD = '[Onbekend]'

UNION

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'Priority'
	, [Missende waarde] = [Priority]
FROM
	[$(OGDW)].Fact.Incident I
	INNER JOIN setup.SourceDefinition SD ON I.SourceDatabaseKey = SD.Code
WHERE 1=1
	AND I.PrioritySTD = '[Onbekend]'
	AND [Priority] IS NOT NULL

UNION

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'EntryType'
	, [Missende waarde] = EntryType
FROM
	[$(OGDW)].Fact.Incident I
	INNER JOIN setup.SourceDefinition SD ON I.SourceDatabaseKey = SD.Code
WHERE 1=1
	AND I.EntryTypeSTD = '[Onbekend]'
	AND EntryType IS NOT NULL

UNION

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'IncidentType'
	, [Missende waarde] = IncidentType
FROM
	[$(OGDW)].Fact.Incident I
	INNER JOIN setup.SourceDefinition SD ON I.SourceDatabaseKey = SD.Code
WHERE 1=1
	AND IncidentTypeSTD = '[Onbekend]'
	AND IncidentType IS NOT NULL

UNION

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'Status'
	, [Missende waarde] = [Status]
FROM
	[$(OGDW)].Fact.Incident I
	INNER JOIN setup.SourceDefinition SD ON I.SourceDatabaseKey = SD.Code
WHERE 1=1
	AND StatusSTD = '[Onbekend]'
	AND [Status] IS NOT NULL

UNION

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'Customer'
	, [Missende waarde] = CustomerName
FROM
	[$(OGDW)].Fact.Incident I
	INNER JOIN setup.SourceDefinition SD ON I.SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.SourceTranslation ST ON I.CustomerName = ST.SourceValue AND SD.DatabaseLabel = ST.SourceName AND ST.DWTableName = 'Incidents' AND ST.DWColumnName = 'CustomerName'
WHERE 1=1
	AND CustomerKey = -1
	AND CustomerAbbreviation = '[Onbekend]'
	AND CustomerName IS NOT NULL
	AND (CustomerName <> SourceValue OR SourceValue IS NULL)

UNION

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'Type'
	, [Missende waarde] = [Type]
FROM
	[$(OGDW)].Fact.Change C
	INNER JOIN setup.SourceDefinition SD ON C.SourceDatabaseKey = SD.Code
WHERE 1=1
	AND TypeSTD = '[Onbekend]'
	AND [Type] IS NOT NULL

UNION

SELECT DISTINCT
	SD.DatabaseLabel
	, Soort = 'CurrentPhase'
	, [Missende waarde] = CurrentPhase
FROM
	[$(OGDW)].Fact.Change C
	INNER JOIN setup.SourceDefinition SD ON C.SourceDatabaseKey = SD.Code
WHERE 1=1
	AND CurrentPhaseSTD = '[Onbekend]'
	AND CurrentPhase IS NOT NULL