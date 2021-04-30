CREATE VIEW [monitoring].[ScheduledJobs]
AS

WITH weekdays AS
(
SELECT *
FROM (VALUES
	(1, 'Sunday', 7)
	, (2, 'Monday', 1)
	, (4, 'Tuesday', 2)
	, (8, 'Wednesday', 3)
	, (16, 'Thursday', 4)
	, (32, 'Friday', 5)
	, (64, 'Saturday', 6)) AS weekdays(mask, maskValue, sortorder)
)

, sysjobhistory AS
(
SELECT
	job_id
	, [server]
	, max_run_duration = CASE WHEN MAX(run_duration) <= 995959 THEN MAX(run_duration) ELSE 995959 END
	, min_run_duration = CASE WHEN MIN(run_duration) <= 995959 THEN MIN(run_duration) ELSE 995959 END
	-- Gemiddelde duur kan niet zomaar berekend worden vanwege notatie run_duration in HHMMSS
--	, avg_run_duration = CASE WHEN AVG(run_duration) <= 995959 THEN AVG(run_duration) ELSE 995959 END
FROM
	msdb.dbo.sysjobhistory
GROUP BY
	job_id
	, [server]
)

SELECT
	[Server] = COALESCE(jh.[server],CONVERT(varchar(max),SERVERPROPERTY('ServerName')))
--	, JobID = j.job_id
	, NextRunDateTime = CASE j.[enabled]
			WHEN 1 THEN CAST(CAST(CASE WHEN js.next_run_date = 0 THEN NULL ELSE js.next_run_date END AS varchar(8)) + ' ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(js.next_run_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':') AS datetime)
			WHEN 0 THEN NULL
		END
	, JobName = COALESCE(j.[name],'[No job assigned]')
	, JobEnabled = CASE j.[enabled]
			WHEN 1 THEN 'Yes'
			WHEN 0 THEN 'No'
			ELSE 'N/A'
		END
	, ScheduleID = COALESCE(CAST(s.schedule_id AS varchar(4)),'N/A')
	, ScheduleName = COALESCE(s.[name],'[No schedule assigned]')
	, ScheduleEnabled = CASE s.[enabled]
			WHEN 1 THEN 'Yes'
			WHEN 0 THEN 'No'
			ELSE 'N/A'
		END
	, Frequency = CASE WHEN s.freq_type < 64 THEN 'Occurs ' ELSE '' END + CASE s.freq_type
			WHEN 1 THEN 'once'
			WHEN 4 THEN CASE s.freq_interval WHEN 1 THEN 'every day' ELSE 'every ' + CAST(s.freq_interval AS varchar(5)) + ' days' END
			WHEN 8 THEN CASE
					WHEN s.freq_recurrence_factor <> 0 AND s.freq_recurrence_factor = 1 THEN 'every week on '
					WHEN s.freq_recurrence_factor <> 0 THEN 'every ' + CAST(s.freq_recurrence_factor AS varchar(10)) + ' weeks on'
				END +
				STUFF((
					SELECT ', ' + maskValue
					FROM weekdays
					WHERE s.freq_interval & mask <> 0
					ORDER BY sortorder
					FOR XML PATH(''))
				, 1, 2, '')
			WHEN 16 THEN 'On day ' + CAST(s.freq_interval AS varchar(10)) + ' of every ' + CAST(s.freq_recurrence_factor AS varchar(10)) + ' months'
			WHEN 32 THEN CASE
					WHEN s.freq_recurrence_factor <> 0 AND s.freq_recurrence_factor = 1 THEN 'every month'
					WHEN s.freq_recurrence_factor <> 0 THEN 'every ' + CAST(s.freq_recurrence_factor AS varchar(10)) + ' months'
				END + ' on the ' +
				CASE s.freq_relative_interval
					WHEN 1 THEN 'First'
					WHEN 2 THEN 'Second'
					WHEN 4 THEN 'Third'
					WHEN 8 THEN 'Fourth'
					WHEN 16 THEN 'Last'
				END +
				CASE s.freq_interval
					WHEN 1 THEN ' Sunday'
					WHEN 2 THEN ' Monday'
					WHEN 3 THEN ' Tuesday'
					WHEN 4 THEN ' Wednesday'
					WHEN 5 THEN ' Thursday'
					WHEN 6 THEN ' Friday'
					WHEN 7 THEN ' Saturday'
					WHEN 8 THEN ' Day'
					WHEN 9 THEN ' Weekday'
					WHEN 10 THEN ' Weekend'
				END
			WHEN 64 THEN 'Start automatically when SQL Server Agent starts'
			WHEN 128 THEN 'Idle'
			ELSE 'N/A'
		END
	, SubFrequency = CASE
			WHEN s.freq_subday_type = 0 THEN 'At request'
			WHEN s.freq_subday_type = 1 THEN 'Once at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
			WHEN s.freq_subday_type > 1 THEN 'Every ' + CAST(s.freq_subday_interval AS varchar(10)) + CASE s.freq_subday_type
					WHEN 2 THEN ' second(s) '
					WHEN 4 THEN ' minute(s) '
					WHEN 8 THEN ' hour(s) '
				END
				+ 'between '
				+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(s.active_start_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
				+ ' and '
				+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(s.active_end_time AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
			ELSE 'N/A'
		END
	, MaxDuration = STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(jh.max_run_duration AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
	, MinDuration = STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(jh.min_run_duration AS varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
	, FailNotifyName = COALESCE(CASE WHEN o.[enabled] = 0 THEN 'Disabled: ' ELSE '' END + o.[name],'None')
	, FailNotifyEmail = COALESCE(o.email_address,'None')
FROM
	msdb.dbo.sysjobs j
	LEFT OUTER JOIN msdb.dbo.sysjobschedules js ON j.job_id = js.job_id
	FULL OUTER JOIN msdb.dbo.sysschedules s ON js.schedule_id = s.schedule_id
	LEFT OUTER JOIN sysjobhistory jh ON j.job_id = jh.job_id
	LEFT OUTER JOIN msdb.dbo.sysoperators o ON j.notify_email_operator_id = o.id
/*
ORDER BY
	j.[enabled] DESC
	, s.[enabled] DESC
	, NextRunDateTime
	, Frequency
	, SubFrequency
	, JobName
*/