CREATE PROCEDURE [monitoring].[CheckFailedFileImports]
(
	@period int = 24
	, @sendmail bit = 0
)
AS 

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.FailedFileImports WHERE DWDateCreated >= DATEADD(HH,-@period,GETDATE()))
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Failed File Imports'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>ID</th>
				<th width="100">DWDateCreated</th>
				<th>AuditDWKey</th>
				<th>SDK</th>
				<th>DatabaseLabel</th>
				<th>SourceFileType</th>
				<th>ErrorMessage</th>
			</tr>
			' + (
			SELECT
				td = FailedFileImportID
				, td = DWDateCreated
				, td = AuditDWKey
				, td = SourceDatabaseKey
				, td = DatabaseLabel
				, td = SourceFileType
				, td = COALESCE(ErrorMessage,'NULL')
			FROM
				monitoring.FailedFileImports
			WHERE 1=1
				AND DWDateCreated >= DATEADD(HH,-@period,GETDATE())
			ORDER BY
				DWDateCreated
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT * FROM monitoring.FailedFileImports WHERE DWDateCreated >= DATEADD(HH,-@period,GETDATE()) ORDER BY DWDateCreated

END