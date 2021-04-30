select 
	 originating_server
	,name
	,enabled
	,run_date
	,run_time
	,Last_RUN_DATETIME =
		-- convert date
		dateadd(dd,((run_date)%100)-1,
		dateadd(mm,((run_date)/100%100)-1,
		dateadd(yy,(nullif(run_date,0)/10000)-1900,0)))+
		-- convert time
		dateadd(ss,run_time%100,
		dateadd(mi,(run_time/100)%100,
		dateadd(hh,run_time/10000,0)))
	,run_duration
	,run_status
	,next_run_date
	,next_run_time
	,NEXT_RUN_DATETIME =
		-- convert date
		dateadd(dd,((next_run_date)%100)-1,
		dateadd(mm,((next_run_date)/100%100)-1,
		dateadd(yy,(nullif(next_run_date,0)/10000)-1900,0)))+
		-- convert time
		dateadd(ss,next_run_time%100,
		dateadd(mi,(next_run_time/100)%100,
		dateadd(hh,next_run_time/10000,0)))
from msdb.dbo.sysjobhistory H
join msdb.dbo.sysjobs_view vw ON (vw.job_id = h.job_id)
join msdb.dbo.sysjobschedules S ON (S.job_id = h.job_id)
where vw.name LIKE 'Backup%' and step_id = 0 