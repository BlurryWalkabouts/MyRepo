CREATE PROCEDURE [monitoring].[CheckMissingIncidents]
(
	@recipients nvarchar(max) = 'rapportage@ogd.nl'
)
AS

BEGIN

DECLARE @body nvarchar(max)

SET @body = '
<H1>Missing Incidents</H1>
<table cellpadding="5" cellspacing="0" border="1">
	<tr>
		<th>SourceDatabaseKey</th>
		<th>ConnectionName</th>
		<th>Incidentnummer</th>
	</tr>
	' + (
	SELECT
		td = SourceDatabaseKey
		, td = ConnectionName
		, td = [Missing Incidents]
	FROM
		monitoring.MissingIncidents
	ORDER BY
		SourceDatabaseKey
		, [Missing Incidents]
	FOR XML RAW('tr'), ELEMENTS
	) + '
</table>'

IF NOT @body = ''
BEGIN
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Rapportageplatform'
		, @recipients = @recipients
		, @subject = 'Missing Incidents'
		, @body = @body
		, @body_format = 'HTML'
END

END