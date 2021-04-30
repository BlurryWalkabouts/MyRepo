CREATE PROCEDURE [monitoring].[CheckMissingStatuses]
(
	@sendmail bit = 0
)
AS

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.MissingStatuses)
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Missing Statuses'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>SourceDatabaseKey</th>
				<th>DatabaseLabel</th>
				<th>Status</th>
				<th>SourceType</th>
			</tr>
			' + (
			SELECT
				td = SourceDatabaseKey
				, td = DatabaseLabel
				, td = [Status]
				, td = SourceType
			FROM
				monitoring.MissingStatuses
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Rapportageplatform', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT * FROM monitoring.MissingStatuses

END