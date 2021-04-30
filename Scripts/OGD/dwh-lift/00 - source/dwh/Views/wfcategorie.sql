CREATE VIEW dwh.[wfcategorie] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [afkorting] = null
FROM dbo.[wfcategorie];
