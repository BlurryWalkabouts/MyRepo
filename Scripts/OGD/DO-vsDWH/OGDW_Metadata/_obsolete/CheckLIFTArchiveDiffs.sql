CREATE PROCEDURE [monitoring].[CheckLIFTArchiveDiffs]
(
	@recipients nvarchar(max)
)
AS

BEGIN

DECLARE @recordCount int
DECLARE @body nvarchar(max)

-- Checks for differences
EXEC monitoring.CompareArchiveToStaging @db = '[$(LIFT_Staging)]', @schema = 'Lift203', @showresult = 0

-- Fill counter with count of diffs
SELECT 
	@recordCount = ISNULL(COUNT(*), 0)
FROM
	##CheckRecordCount
WHERE 1=1
	AND ISNULL(StagingCount,0) <> ISNULL(CurrentCount,0)

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
		WHERE 1=1
			AND ISNULL(StagingCount,0) <> ISNULL(CurrentCount,0)
		FOR XML RAW('tr'), ELEMENTS
		) + '
	</table>'

	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = 'DBA Alerts'
		, @recipients = @recipients
		, @subject = 'LIFT Archive Differences'
		, @body = @body
		, @body_format = 'HTML'
END

END