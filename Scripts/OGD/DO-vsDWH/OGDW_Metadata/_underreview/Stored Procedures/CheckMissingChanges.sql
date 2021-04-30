CREATE PROCEDURE [monitoring].[CheckMissingChanges]
(
	@recipients nvarchar(max) = 'rapportage@ogd.nl'
)
AS

BEGIN

DECLARE @body nvarchar(max)

SET @body = '
<H1>Missing Changes</H1>
<table cellpadding="5" cellspacing="0" border="1">
	<tr>
		<th>SourceDatabaseKey</th>
		<th>ConnectionName</th>
		<th>Changenummer</th>
	</tr>
	' + (
	SELECT
		td = SourceDatabaseKey
		, td = ConnectionName
		, td = [Missing Changes]
	FROM
		monitoring.MissingChanges
	ORDER BY
		SourceDatabaseKey
		, [Missing Changes]
	FOR XML RAW('tr'), ELEMENTS
	) + '
</table>'

IF NOT @body = ''
BEGIN
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Rapportageplatform'
		, @recipients = @recipients
		, @subject = 'Missing Changes'
		, @body = @body
		, @body_format = 'HTML'
END

END