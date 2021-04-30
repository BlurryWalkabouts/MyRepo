CREATE PROCEDURE [monitoring].[CheckMissingCustomerKeys]
(
	@sendmail bit = 0
)
AS

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.MissingCustomerKeys)
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Missing Customer Keys'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>TableName</th>
				<th>SourceDatabaseKey</th>
				<th>DatabaseLabel</th>
				<th>MultipleCustomers</th>
				<th>CustomerName</th>
				<th>Count</th>
			</tr>
			' + (
			SELECT
				td = TableName
				, td = COALESCE(CAST(SourceDatabaseKey AS nvarchar(10)),'NULL')
				, td = COALESCE(DatabaseLabel,'NULL')
				, td = MultipleCustomers
				, td = COALESCE(CustomerName,'NULL')
				, td = MissingCustomerKeyCount
			FROM
				monitoring.MissingCustomerKeys
			ORDER BY
				TableName
				, SourceDatabaseKey
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Rapportageplatform', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT * FROM monitoring.MissingCustomerKeys

END