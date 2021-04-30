CREATE PROCEDURE [monitoring].[CheckOpenIncidents]
(
	@recent bit = 1
	, @sendmail bit = 0
)
AS

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.OpenIncidents WHERE RecentlyImported >= @recent)
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Open Incidents'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>SDK</th>
				<th>DatabaseLabel</th>
				<th>IncidentNumber</th>
				<th>[Status]</th>
				<th>AuditDWKey</th>
				<th>DWDateCreated</th>
				<th>RecentlyImported</th>
			</tr>
			' + (
			SELECT
				td = SourceDatabaseKey
				, td = DatabaseLabel
				, td = IncidentNumber
				, td = COALESCE([Status],'NULL')
				, td = AuditDWKey
				, td = DWDateCreated
				, td = RecentlyImported
			FROM
				monitoring.OpenIncidents
			WHERE 1=1
				AND RecentlyImported >= @recent
			ORDER BY
				SourceDatabaseKey
				, IncidentNumber
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT *
	FROM monitoring.OpenIncidents
	WHERE RecentlyImported >= @recent
	ORDER BY SourceDatabaseKey, IncidentNumber

END