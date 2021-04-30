CREATE PROCEDURE [monitoring].[CheckRowsNotConnecting]
(
	@sendmail bit = 0
)
AS

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.RowsNotConnecting)
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Rows Not Connecting'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>SourceTable</th>
				<th>SourceDatabaseKey</th>
				<th>PrimaryKey</th>
				<th>RowNumber</th>
				<th>AuditDWKey</th>
				<th>ValidFrom</th>
				<th>ValidTo</th>
				<th>NewValidTo</th>
			</tr>
			' + (
			SELECT
				td = DatabaseName + '.' + SchemaName + '.' + TableName
				, td = SourceDatabaseKey
				, td = PrimaryKey
				, td = RowNumber
				, td = AuditDWKey
				, td = ValidFrom
				, td = ValidTo
				, td = NewValidTo
			FROM
				monitoring.RowsNotConnecting
			ORDER BY
				DatabaseName
				, SchemaName
				, TableName
				, SourceDatabaseKey
				, PrimaryKey
				, RowNumber
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT *
	FROM monitoring.RowsNotConnecting
	ORDER BY DatabaseName, SchemaName, TableName, SourceDatabaseKey, PrimaryKey, RowNumber

END