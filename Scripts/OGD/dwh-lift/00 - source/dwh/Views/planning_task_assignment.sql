CREATE VIEW dwh.[planning_task_assignment] AS
SELECT
    pta.[unid],
    pta.[task_assignmentid],
    pta.[startdate],
    [enddate] =  LEAD(pta.[startdate],1,tv.[einddatum]) OVER (PARTITION BY pta.[task_assignmentid] ORDER BY pta.[startdate] ASC, pta.[amount] ASC),
    pta.[amount]
FROM dbo.[planning_task_assignment] pta
INNER JOIN dbo.[taakvoordracht] tv ON pta.[task_assignmentid] = tv.[unid];