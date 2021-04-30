CREATE PROCEDURE [monitoring].[CheckDatabaseRowsCount]
(
	@sendmail bit = 0
)
AS 

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.CurrentDatabaseRowsCount)
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Overview Current Rows Per Database Per SDK'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>Fact</th>
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
				td = rc.Fact
				, td = rc.SourceDatabaseKey
				, td = COALESCE(sd.DatabaseLabel,'NULL')
				, td = COALESCE(sd.SourceType,'NULL')
				, td = rc.ArchiveHistory
				, td = rc.ArchiveParent
				, td = rc.TOPdesk_DW
				, td = rc.NotInParent
			FROM
				monitoring.CurrentDatabaseRowsCount rc
				LEFT OUTER JOIN setup.SourceDefinition sd ON rc.SourceDatabaseKey = sd.Code
			ORDER BY
				Fact
				, SourceDatabaseKey
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT * FROM monitoring.CurrentDatabaseRowsCount ORDER BY Fact, SourceDatabaseKey

END

/*
EXEC monitoring.CheckDWHRowsCount 'Incident', '2017-04-13 06:00'
EXEC monitoring.CheckDWHRowsCount 'Change', '2017-04-13 06:00'
EXEC monitoring.CheckDWHRowsCount 'ChangeActivity', '2017-04-13 06:00'
EXEC monitoring.CheckDWHRowsCount 'Problem', '2017-04-13 06:00'
*/