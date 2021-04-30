CREATE VIEW dwh.[planning_assignment] AS
SELECT
    pa.[unid],
    pa.[assignmentid],
    pa.[startdate],
    [enddate] =  LEAD(pa.[startdate],1,v.[einddatum]) OVER (PARTITION BY pa.[assignmentid] ORDER BY pa.[startdate] ASC, pa.[amount] ASC),
    pa.[amount]
FROM dbo.[planning_assignment] pa
INNER JOIN dbo.[voordracht] v ON pa.[assignmentid] = v.[unid];