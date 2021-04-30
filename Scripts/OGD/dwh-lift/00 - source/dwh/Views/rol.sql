CREATE VIEW dwh.[rol] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [afkorting] = null
FROM dbo.[rol];
