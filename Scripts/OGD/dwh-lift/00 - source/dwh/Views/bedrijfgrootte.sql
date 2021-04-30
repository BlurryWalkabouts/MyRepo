CREATE VIEW dwh.[bedrijfgrootte] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [afkorting] = null
FROM dbo.[bedrijfgrootte];
