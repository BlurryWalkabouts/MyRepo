CREATE VIEW [monitoring].[CurrentDatabaseRowsCount]
AS

-- Neem de laatste rij per feit, database en SDK, maar maximaal een week oud
WITH DatabaseRowsCount AS
(
SELECT
	Fact
	, DatabaseName
	, SourceDatabaseKey
	, RowsCount
	, RowNumber = ROW_NUMBER() OVER (PARTITION BY Fact, DatabaseName, SourceDatabaseKey ORDER BY MonitoringDate DESC)
FROM
	monitoring.DatabaseRowsCount
WHERE 1=1
	AND MonitoringDate > GETDATE()-7
)

-- En dan lekker pivoten
SELECT
	Fact
	, SourceDatabaseKey
	, AM
	, OGDW
	, ArchiveHistory
	, ArchiveParent
	, TOPdesk_DW
	, NotInParent = ArchiveHistory - ArchiveParent
	, NotInTDDW = OGDW - TOPdesk_DW
FROM
	(SELECT Fact, DatabaseName, SourceDatabaseKey, RowsCount FROM DatabaseRowsCount WHERE RowNumber = 1) x
	PIVOT (SUM(RowsCount) FOR DatabaseName IN (AM, OGDW, ArchiveHistory, ArchiveParent, TOPdesk_DW)) y