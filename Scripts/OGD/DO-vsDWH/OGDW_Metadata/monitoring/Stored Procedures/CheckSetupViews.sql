CREATE PROCEDURE [monitoring].[CheckSetupViews]
(
	@sendmail bit = 0
)
AS

BEGIN

DECLARE @table_name sysname = ''
DECLARE @table_schema sysname = 'setup'
DECLARE @SQLString nvarchar(max)
DECLARE @failed nvarchar(max) = ''

DECLARE V CURSOR FOR
(
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = @table_schema
)

OPEN V
FETCH NEXT FROM V INTO @table_schema, @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQLString =  'SELECT TOP 0 * FROM ' + @table_schema + '.' + @table_name + ';'

	BEGIN TRY
		-- if .. geeft correct resultaat dan hoeven we hier niets mee te doen
		EXEC (@SQLString)
	END TRY

	BEGIN CATCH
--		PRINT 'FOUT, view ' + @table_name+ ' werkt niet!'
		SET @failed += @table_schema + '.' + @table_name + ', ERROR: ' + CAST(ERROR_NUMBER() AS varchar(max))+ '' + char(10) + CAST(ERROR_MESSAGE() AS varchar(max)) + char(10) + char(10)
/*
		SELECT 
			ErrorNumber = ERROR_NUMBER()
			, ErrorSeverity = ERROR_SEVERITY()
			, ErrorState = ERROR_STATE()
			, ErrorProcedure = ERROR_PROCEDURE()
			, ErrorLine = ERROR_LINE()
			, ErrorMessage = ERROR_MESSAGE()
*/
	END CATCH

	FETCH NEXT FROM V INTO @table_schema, @table_name
END

CLOSE V
DEALLOCATE V

IF @sendmail = 1
BEGIN
	IF @failed <> ''
	BEGIN
		DECLARE @subject nvarchar(64) = 'Gefaalde queries'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @body = 'Stelletje achterlijke faalhazen! Dit zijn de views die het niet doen: ' + char(10) + @failed

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Rapportageplatform', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
	PRINT @failed

END