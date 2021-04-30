CREATE PROCEDURE [monitoring].[CheckStagingVsArchive]
(
	@dbStaging nvarchar(64)
	, @schemaStaging nvarchar(64)
	, @dbArchive nvarchar(64)
	, @schemaArchive nvarchar(64)
	, @sendmail bit = 0
)
AS

BEGIN

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)
DECLARE @table_name sysname

DROP TABLE IF EXISTS #CheckRecordCount
CREATE TABLE #CheckRecordCount
(
	TABLE_NAME sysname
	, Staging int
	, ArchiveParent int
	, ArchiveHistory int
	, DeltaStaging int
) 

SET @SQLString = '
INSERT INTO
	#CheckRecordCount
	(
	TABLE_NAME
	)
SELECT
	TABLE_NAME
FROM
	' + @dbStaging + '.INFORMATION_SCHEMA.TABLES
WHERE 1=1
	AND TABLE_SCHEMA = ''' + @schemaStaging + '''
	AND TABLE_TYPE = ''BASE TABLE''
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM ' + @dbStaging + '.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = ''unid'')'

EXEC (@SQLString)

DECLARE T CURSOR FOR
(
SELECT TABLE_NAME FROM #CheckRecordCount
)

OPEN T
FETCH NEXT FROM T INTO @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQLString = '
	UPDATE
		#CheckRecordCount 
	SET
		Staging = (SELECT COUNT(DISTINCT unid) FROM ' + @dbStaging + '.' + @schemaStaging + '.' + @table_name + ')
		, ArchiveParent = (SELECT COUNT(DISTINCT unid) FROM ' + @dbArchive + '.' + @schemaArchive + '.' + @table_name + ')
		, ArchiveHistory = (SELECT COUNT(DISTINCT unid) FROM ' + @dbArchive + '.History.' + @table_name + ')
	WHERE 1=1
		AND TABLE_NAME = ''' + @table_name + ''''

	EXEC (@SQLString)

	FETCH NEXT FROM T INTO @table_name
END

CLOSE T
DEALLOCATE T

UPDATE
	#CheckRecordCount
SET
	DeltaStaging = Staging - ArchiveParent

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM #CheckRecordCount
/*
	-- LIFT
	WHERE 1=1
		AND ISNULL(Staging,0) <> ISNULL(ArchiveParent,0)
*/
/*
	-- OGDW
	WHERE 1<>1
		OR (ArchiveParent = 0 AND Staging <> 0)
		-- current kan minder unids bevatten dan staging wanneer records niet 
		-- MEER worden aangeleverd en dus wel in staging zitten maar niet in Current
	   OR (ArchiveParent > Staging 
		-- Voor truncate tabellen geld,current kan meer unids hebben dan staging wanneer het om delta gaat. 
		-- Verdwenen recs worden niet verwijderd uit archive, wel uit staging. Voor nu filteren
	   AND TABLE_NAME NOT IN ('incident','Incidents','Changes'))
*/
	)
	BEGIN
		DECLARE @subject nvarchar(64) = 'Database Differences'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @subject = @dbArchive + ' ' + @subject
		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>TableName</th>
				<th>Staging</th>
				<th>ArchiveParent</th>
				<th>ArchiveHistory</th>
				<th>Staging - Parent</th>
			</tr>
			' + (
			SELECT
				td = TABLE_NAME
				, td = Staging
				, td = ArchiveParent
				, td = ArchiveHistory
				, td = DeltaStaging
			FROM
				#CheckRecordCount
/*
			-- LIFT
			WHERE 1=1
				AND ISNULL(Staging,0) <> ISNULL(ArchiveParent,0)
*/
/*
			-- OGDW
			WHERE 1<>1
				OR (ArchiveParent = 0 AND Staging <> 0)
				OR (ArchiveParent > Staging AND TABLE_NAME NOT IN ('incident','Incidents','Changes'))
*/
			ORDER BY
				TABLE_NAME
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT * FROM #CheckRecordCount ORDER BY TABLE_NAME

END