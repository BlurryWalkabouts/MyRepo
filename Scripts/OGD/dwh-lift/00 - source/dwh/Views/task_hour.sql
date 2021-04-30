CREATE VIEW dwh.[task_hour] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [datum],
    [taskid],
    [employeeid],
    [seconds],
    [old_amount]
FROM dbo.[task_hour];
