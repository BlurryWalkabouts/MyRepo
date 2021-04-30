CREATE VIEW dwh.[verantwoording] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [type],
    [afkorting] = null
FROM dbo.[verantwoording];
