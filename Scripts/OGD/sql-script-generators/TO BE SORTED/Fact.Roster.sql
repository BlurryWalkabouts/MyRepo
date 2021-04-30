select
   RosterId = hr.id
  ,EmployeeKey = hr.resource_id
  ,Date = hr.rosterdate
  ,Rosterline = hr.rosterline
  ,[ShiftKey] = COALESCE(hi.shift_id, hr.[shift_id], -1)
  ,[PositionKey] = COALESCE (NULLIF (hr.[plannedprop_id], ''), -1)
  ,[AbsenceReasonKey] = coalesce(hr.dayabsence_id, -1)
  ,[PeriodeAbsenceReasonKey] = coalesce(hr.periodabsence_id, -1)
  ,[ResourceGroupKey] = coalesce(lh.resourcegroup_id, -1)
  ,[OverRulingResourceGroupKey] = coalesce(hr.overrulinggroup_id, -1)
  ,[nr] = coalesce(hr.[nr], hi.nr, lh.nr, -1)
  ,RosterDaypartCount
    ,[TimeTypeKey] = coalesce(hi.[timetype_id], -1)
    ,[Phase] = CASE hr.[rosterline]
        WHEN 0 THEN 'P' -- Pattern
        WHEN 4 THEN 'R' -- Realized
        ELSE CAST(hr.[rosterline] AS NCHAR(1)) -- Phase#
    END
    ,[StartTime] = COALESCE(CAST(hi.[starttime] AS TIME), '00:00:00')
    ,[EndTime] = COALESCE(CAST(hi.[endtime] AS TIME), '00:00:00')
from dbo.hist_roster hr
left join dbo.hist_timeinterval hi on (hi.id = hr.id)
left join dbo.hist_labourhist lh on (hr.labourhist_id = lh.id)
order by date, employeekey, rosterline