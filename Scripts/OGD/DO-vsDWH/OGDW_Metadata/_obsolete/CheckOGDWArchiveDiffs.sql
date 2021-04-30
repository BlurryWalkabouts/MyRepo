CREATE PROCEDURE [monitoring].[CheckOGDWArchiveDiffs]
(
	@recipients nvarchar(max)
)
AS

BEGIN

DECLARE @recordCount int
DECLARE @body nvarchar(max)

-- Checks for differences
EXEC monitoring.CompareArchiveToStaging @db = '[$(OGDW_Staging)]', @schema = 'TOPdesk', @showresult = 0

-- Fill counter with count of diffs
SELECT 
	@recordCount = ISNULL(COUNT(*), 0)
FROM
	##CheckRecordCount
WHERE 1<>1
	OR (CurrentCount = 0 AND StagingCount <> 0)
	-- current kan minder unids bevatten dan staging wanneer records niet 
	-- MEER worden aangeleverd en dus wel in staging zitten maar niet in Current
   OR (CurrentCount > StagingCount 
	-- Voor truncate tabellen geld,current kan meer unids hebben dan staging wanneer het om delta gaat. 
	-- Verdwenen recs worden niet verwijderd uit archive, wel uit staging. Voor nu filteren
   AND table_name NOT IN ('incident','Incidents','Changes'))

IF(@recordCount > 0)
BEGIN
	SET @body = '
	<table cellpadding="5" cellspacing="0" border="1">
		<tr>
			<th>TableName</th>
			<th>StagingCount</th>
			<th>CurrentCount</th>
			<th>HistoryCount</th>
		</tr>
		' + (
		SELECT
			td = TableName
			, td = StagingCount
			, td = CurrentCount
			, td = HistoryCount
		FROM
			##CheckRecordCount
		WHERE 1<>1
			OR (CurrentCount = 0 AND StagingCount <> 0)
			OR (CurrentCount > StagingCount AND table_name NOT IN ('incident','Incidents','Changes'))
		FOR XML RAW('tr'), ELEMENTS
		) + '
	</table>'

	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'DBA Alerts'
		, @recipients = @recipients
		, @subject = 'OGDW Archive Differences'
		, @body = @body
		, @body_format = 'HTML'
END

END