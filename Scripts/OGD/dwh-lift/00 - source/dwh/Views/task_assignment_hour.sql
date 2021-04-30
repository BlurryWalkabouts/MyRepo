CREATE VIEW dwh.[task_assignment_hour] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [datum],
    [task_assignmentid],
    [seconds],
    [old_amount]
FROM dbo.[task_assignment_hour];
