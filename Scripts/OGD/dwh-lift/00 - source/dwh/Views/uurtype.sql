CREATE VIEW dwh.[uurtype] AS
SELECT
    [unid],
    [projectid],
    [looncomponent_urenid],
    [procent],
    [tariefnaam],
    [declarabel],
    [start_date],
    [end_date]
FROM dbo.[uurtype];
