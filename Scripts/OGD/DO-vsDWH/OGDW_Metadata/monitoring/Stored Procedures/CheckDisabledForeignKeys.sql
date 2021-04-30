CREATE PROCEDURE [monitoring].[CheckDisabledForeignKeys]
(
	@period int = 24
	, @sendmail bit = 0
)
AS

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.DisabledForeignKeys WHERE DisableDate BETWEEN DATEADD(HH,-@period-1,GETDATE()) AND DATEADD(HH,-1,GETDATE()))
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Disabled Foreign Keys'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>Database Name</th>
				<th>Foreign Key</th>
			</tr>
			' + (
			SELECT
				td = DbName
				, td = ForeignKey
			FROM
				monitoring.DisabledForeignKeys
			WHERE 1=1
				AND DisableDate BETWEEN DATEADD(HH,-@period-1,GETDATE()) AND DATEADD(HH,-1,GETDATE())
			ORDER BY
				DbName
				, ForeignKey
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT * FROM monitoring.DisabledForeignKeys WHERE DisableDate BETWEEN DATEADD(HH,-@period-1,GETDATE()) AND DATEADD(HH,-1,GETDATE())

END