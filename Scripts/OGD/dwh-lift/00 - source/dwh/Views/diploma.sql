CREATE VIEW dwh.[diploma] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [afkorting] = null
FROM dbo.[diploma];
