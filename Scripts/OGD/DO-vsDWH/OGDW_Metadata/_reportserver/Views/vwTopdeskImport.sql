CREATE VIEW [log].[vwTopdeskImport]
AS

/* Deze view wordt gebruikt in het rapport 'Log_Topdesk_Import' */

WITH LastImport AS
(
SELECT
	SourceDatabaseKey
	, AuditDWkey = MAX(AuditDWKey)
	, DWDateCreated = MAX(DWDateCreated)
FROM
	[log].[Audit]
WHERE 1=1
	AND DWDateCreated IS NOT NULL
GROUP BY
	SourceDatabaseKey
)

SELECT
	[Source] = LEFT(ConnectionName,CHARINDEX('_',ConnectionName)-1)
	, [Type] = RIGHT(ConnectionName,LEN(ConnectionName)-CHARINDEX('_',ConnectionName))
	, LastImportDate = MAX(I.DWDateCreated)
	, ImportedIntoStaging = MAX(RecordCount)
--	, NewOrChangedIncidents = MAX(IN_count)
--	, NewOrChangedChanges = MAX(CH_count)
--	, NewOrChangedCallers= MAX(CA_count)
	, LastCompleteWeek = DATEPART(WW,MAX(I.DWDateCreated))-1
	, WeekDataCurrent = IIF(DATEPART(WW,CURRENT_TIMESTAMP) = (DATEPART(WW,MAX(I.DWDateCreated))),1,0)
	, LastCompleteMonth = DATEPART(MM,MAX(I.DWDateCreated))-1
	, MonthDataCurrent = IIF(DATEPART(MM,CURRENT_TIMESTAMP) = (DATEPART(MM,MAX(I.DWDateCreated))),1,0)
FROM
	LastImport I
	LEFT OUTER JOIN [log].StagingRecordCount SC ON SC.AuditDWKey = I.AuditDWKey
--	LEFT OUTER JOIN [log].AnchorRecordCount AC ON AC.AuditDWKey = I.AuditDWKey
	LEFT OUTER JOIN setup.SourceDefinition S ON I.SourceDatabaseKey = S.Code
WHERE 1=1
	AND ConnectionName NOT IN ('CSM_incidents') -- Ex klanten wegfilteren
GROUP BY
	S.Code
	, LEFT(ConnectionName,CHARINDEX('_',ConnectionName)-1)
	, RIGHT(ConnectionName,LEN(ConnectionName)-CHARINDEX('_',ConnectionName))