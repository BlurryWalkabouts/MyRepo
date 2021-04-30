CREATE VIEW dwh.[regio] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [afkorting] = null
FROM dbo.[regio];
