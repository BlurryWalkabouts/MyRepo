CREATE VIEW dwh.[afspraak_resultaat] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [afkorting]= null
FROM dbo.[afspraak_resultaat];
