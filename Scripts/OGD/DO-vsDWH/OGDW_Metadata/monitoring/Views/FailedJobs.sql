CREATE VIEW [monitoring].[FailedJobs]
AS

WITH sysjobhistory AS
(
SELECT
	RunDateTime = CAST(CAST(h.run_date AS varchar(8)) + ' ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(h.run_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') AS datetime)
	, Duration = ((h.run_duration/10000 * 3600) + ((h.run_duration%10000)/100*60) + (h.run_duration%10000)%100 /* run_duration_elapsed_seconds */) / (24.0*3600 /* seconds in a day */)
	, DurationDays = CAST(h.run_duration/10000/24 AS varchar(3))
	, [Server] = h.[server]
	, Job = j.[name]
	, Step = h.step_name
	, [Message] = h.[message]
FROM
	msdb.dbo.sysjobhistory h
	INNER JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id 
WHERE 1=1
	AND run_status NOT IN (1,4) -- 0 = Failed, 1 = Succeeded, 2 = Retry, 3 = Canceled, 4 = In progress, 5 = Unknown
	AND h.step_name <> '(Job outcome)'
)

SELECT
	RunDateTime
	, Duration = RIGHT('00' + DurationDays, 2) + 'd' + CAST(CAST(CAST(Duration AS datetime) AS time(0)) AS varchar(8))
	, EndDateTime = RunDateTime + Duration
	, [Server]
	, Job
	, Step
	, [Message]
FROM
	sysjobhistory