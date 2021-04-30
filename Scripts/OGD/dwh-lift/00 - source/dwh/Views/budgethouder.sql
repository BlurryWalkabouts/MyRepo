CREATE VIEW dwh.[budgethouder] AS
SELECT
    [unid],
    [archief],
    [rang],
    [type],
    [tekst],
    [projectverplicht],
    [contractretour],
    [kostendrager],
    [kostenplaats],
    [afkorting] = null
FROM dbo.[budgethouder];
