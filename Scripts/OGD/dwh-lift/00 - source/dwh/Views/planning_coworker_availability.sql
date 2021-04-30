CREATE VIEW dwh.[planning_coworker_availability] AS
SELECT
    [unid],
    [coworkerid],
    [startdate],
    [amount]
FROM dbo.[planning_coworker_availability];
