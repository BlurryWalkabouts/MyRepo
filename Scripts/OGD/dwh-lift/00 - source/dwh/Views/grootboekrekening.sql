CREATE VIEW dwh.[grootboekrekening] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [omschrijving],
    [kostendrager],
    [kostenplaats],
    [type],
    [belast],
    [afkorting] = null
FROM dbo.[grootboekrekening];
