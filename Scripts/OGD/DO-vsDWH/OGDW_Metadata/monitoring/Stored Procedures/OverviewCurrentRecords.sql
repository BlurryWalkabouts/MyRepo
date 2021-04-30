CREATE PROCEDURE [monitoring].[OverviewCurrentRecords]
(
	@facttable nvarchar(64)
	, @sendmail bit = 0
	, @timestamp nvarchar(32) = NULL
	, @debug bit = 0
)
AS 

BEGIN

SET NOCOUNT ON

SET @timestamp = COALESCE(@timestamp,SYSDATETIME())

DECLARE @table nvarchar(64) = REPLACE(LOWER(@facttable),'problem','probleem')
DECLARE @businesskey nvarchar(64) = REPLACE(@facttable,'ChangeActivity','Activity') + 'Number'
DECLARE @SQLString nvarchar(max)

CREATE TABLE #OverviewCurrentRecords
(
	SourceDatabaseKey int
	, DatabaseLabel nvarchar(32)
	, SourceType nvarchar(32)
	, ArchiveHistory int
	, ArchiveParent int
	, TOPdesk_DW int
	, NotInParent int
)

SET @SQLString = '
WITH Archive AS
(
SELECT
	SourceDatabaseKey = COALESCE(SourceDatabaseKey,-1)
	, Aantal = COUNT(unid)
FROM
	(
	SELECT SourceDatabaseKey, unid FROM [$(OGDW_Archive)].TOPdesk.' + @table + '
	UNION
	SELECT SourceDatabaseKey, unid FROM [$(OGDW_Archive)].history.' + @table + '
	) x
GROUP BY
	SourceDatabaseKey'
+ IIF(@facttable IN ('Incident','Change'),'
UNION
SELECT
	SourceDatabaseKey = COALESCE(SourceDatabaseKey,-1)
	, Aantal = COUNT(' + @businesskey + ')
FROM
	(
	SELECT SourceDatabaseKey, ' + @businesskey + ' FROM [$(OGDW_Archive)].fileimport.' + @table + 's
	UNION
	SELECT SourceDatabaseKey, ' + @businesskey + ' FROM [$(OGDW_Archive)].history.' + @table + 's
	) x
GROUP BY
	SourceDatabaseKey','') + '
)

, Parent AS
(
SELECT
	SourceDatabaseKey = COALESCE(SourceDatabaseKey,-1)
	, Aantal = COUNT(unid)
FROM
	[$(OGDW_Archive)].TOPdesk.' + @table + ' FOR SYSTEM_TIME AS OF ''' + @timestamp + '''
GROUP BY
	SourceDatabaseKey'
+ IIF(@facttable IN ('Incident','Change'),'
UNION
SELECT
	SourceDatabaseKey = COALESCE(SourceDatabaseKey,-1)
	, Aantal = COUNT(' + @businesskey + ')
FROM
	[$(OGDW_Archive)].fileimport.' + @table + 's FOR SYSTEM_TIME AS OF ''' + @timestamp + '''
GROUP BY
	SourceDatabaseKey','') + '
)

, TOPdesk_DW AS
(
SELECT
	SourceDatabaseKey = COALESCE(SourceDatabaseKey,-1)
	, Aantal = COUNT(' + @businesskey + ')
FROM
	[$(OGDW)].Fact.' + @facttable + '
GROUP BY
	SourceDatabaseKey
)

INSERT INTO
	#OverviewCurrentRecords
	(
	SourceDatabaseKey
	, DatabaseLabel
	, SourceType
	, ArchiveHistory
	, ArchiveParent
	, TOPdesk_DW
	, NotInParent
	)
SELECT
	SourceDatabaseKey = COALESCE(a.SourceDatabaseKey, p.SourceDatabaseKey, td.SourceDatabaseKey)
	, sd.DatabaseLabel
	, sd.SourceType
	, Archive = COALESCE(a.Aantal,0)
	, Parent = COALESCE(p.Aantal,0)
	, TOPdesk_DW = COALESCE(td.Aantal,0)
	, NotInParent = COALESCE(p.Aantal,0) - COALESCE(a.Aantal,0)
FROM
	Archive a
	FULL OUTER JOIN Parent p ON a.SourceDatabaseKey = p.SourceDatabaseKey
	FULL OUTER JOIN TOPdesk_DW td ON a.SourceDatabaseKey = td.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceDefinition sd ON a.SourceDatabaseKey = sd.Code'

IF @debug = 0
BEGIN
	EXEC (@SQLString)

	IF @sendmail = 1
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM #OverviewCurrentRecords)
		BEGIN
			-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
			DECLARE @subject nvarchar(64) = 'Overview Current Records'
			DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
			DECLARE @body nvarchar(max)

			SET @subject = @subject + ' ' + @facttable
			SET @body = '
			<H1>' + @subject + '</H1>
			<table cellpadding="5" cellspacing="0" border="1">
				<tr>
					<th>SourceDatabaseKey</th>
					<th>DatabaseLabel</th>
					<th>SourceType</th>
					<th>ArchiveHistory</th>
					<th>ArchiveParent</th>
					<th>TOPdesk_DW</th>
					<th>NotInParent</th>
				</tr>
				' + (
				SELECT
					td = SourceDatabaseKey
					, td = COALESCE(DatabaseLabel,'NULL')
					, td = COALESCE(SourceType,'NULL')
					, td = ArchiveHistory
					, td = ArchiveParent
					, td = TOPdesk_DW
					, td = NotInParent
				FROM
					#OverviewCurrentRecords
				ORDER BY
					SourceDatabaseKey
				FOR XML RAW('tr'), ELEMENTS
				) + '
			</table>'

			IF @recipients IS NOT NULL
				EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
		END
	END
	ELSE
		SELECT * FROM #OverviewCurrentRecords ORDER BY SourceDatabaseKey
END
ELSE
	PRINT @SQLString

END

/*
EXEC monitoring.OverviewCurrentRecords 'Incident', '', '2017-04-13 06:00', 1
EXEC monitoring.OverviewCurrentRecords 'Change', '', '2017-04-13 06:00', 1
EXEC monitoring.OverviewCurrentRecords 'ChangeActivity', '', '2017-04-13 06:00', 1
EXEC monitoring.OverviewCurrentRecords 'Problem', '', '2017-04-13 06:00', 1
*/