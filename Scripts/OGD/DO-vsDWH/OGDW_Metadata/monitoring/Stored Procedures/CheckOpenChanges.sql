CREATE PROCEDURE [monitoring].[CheckOpenChanges]
(
	@recent bit = 1
	, @sendmail bit = 0
)
AS

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.OpenChanges WHERE RecentlyImported >= @recent)
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Open Changes'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>SDK</th>
				<th>DatabaseLabel</th>
				<th>ChangeNumber</th>
				<th>CurrentPhase</th>
				<th>[Status]</th>
				<th>AuditDWKey</th>
				<th>DWDateCreated</th>
				<th>RecentlyImported</th>
			</tr>
			' + (
			SELECT
				td = SourceDatabaseKey
				, td = DatabaseLabel
				, td = ChangeNumber
				, td = COALESCE(CurrentPhase,'NULL')
				, td = COALESCE([Status],'NULL')
				, td = AuditDWKey
				, td = DWDateCreated
				, td = RecentlyImported
			FROM
				monitoring.OpenChanges
			WHERE 1=1
				AND RecentlyImported >= @recent
			ORDER BY
				SourceDatabaseKey
				, ChangeNumber
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT *
	FROM monitoring.OpenChanges
	WHERE RecentlyImported >= @recent
	ORDER BY SourceDatabaseKey, ChangeNumber

END