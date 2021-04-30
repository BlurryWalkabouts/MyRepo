CREATE VIEW dwh.[acquisition_goal] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [afkorting] = null,
    [klant1_visible],
    [klant2_visible],
    [contactpersoon1_visible],
    [project_visible]
FROM dbo.[acquisition_goal];
