CREATE VIEW [monitoring].[MissingStatuses]
AS

-- Haalt statussen waardes op uit archive
WITH cte AS
(
-- FILE IMPORT
SELECT [Status], SourceDatabaseKey
FROM [$(OGDW_Archive)].FileImport.Incidents
UNION
-- DB IMPORT
SELECT [Status] = naam, SourceDatabaseKey
FROM [$(OGDW_Archive)].TOPdesk.afhandelingstatus
)

, CTE_CheckStatusSTD AS
(
SELECT
	cte.[Status]
	, cte.SourceDatabaseKey
	, SD.DatabaseLabel
	, SD.SourceType
FROM
	cte
	INNER JOIN setup.SourceDefinition SD ON cte.SourceDatabaseKey = SD.Code
)

--SELECT * FROM CTE_CheckStatusSTD

-- Hier worden de statussen gefilterd die nog niet in [MDS].[mdm].[SourceTranslation] zitten.
SELECT
	A.SourceDatabaseKey
	, A.DatabaseLabel
	, A.[Status]
	, A.SourceType
FROM
	CTE_CheckStatusSTD A
	LEFT OUTER JOIN setup.SourceTranslation B ON A.DatabaseLabel = B.SourceName AND A.[Status] = B.SourceValue -- AND B.DWColumnName2 = 'Status'
WHERE 1=1
	AND B.SourceValue IS NULL
	AND A.[Status] NOT IN (SELECT DISTINCT SourceValue FROM setup.SourceTranslation WHERE SourceName = 'Default')