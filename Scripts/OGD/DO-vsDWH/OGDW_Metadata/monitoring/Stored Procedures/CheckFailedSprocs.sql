CREATE PROCEDURE [monitoring].[CheckFailedSprocs]
(
	@period int = 24
	, @sendmail bit = 0
)
AS

BEGIN

IF @sendmail = 1
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM monitoring.FailedSprocs WHERE StartDate >= DATEADD(HH,-@period,GETDATE()))
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Failed ETL Sprocs'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th>LogDate</th>
				<th>ProcedureName</th>
				<th>ErrorNumber</th>
				<th>ErrorMessage</th>
				<th>AdditionalInfo</th>
			</tr>
			' + (
			SELECT
				td = StartDate
				, td = ProcedureName
				, td = ErrorNumber
				, td = ErrorMessage
				, td = AdditionalInfo
			FROM
				monitoring.FailedSprocs
			WHERE 1=1
				AND StartDate >= DATEADD(HH,-@period,GETDATE())
			ORDER BY
				StartDate
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	SELECT * FROM monitoring.FailedSprocs WHERE StartDate >= DATEADD(HH,-@period,GETDATE())

END