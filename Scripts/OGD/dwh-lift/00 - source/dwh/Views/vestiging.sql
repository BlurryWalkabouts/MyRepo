CREATE VIEW dwh.[vestiging] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [bedrijfid],
    [kostendrager],
    [kostenplaats],
    [afkorting]
FROM dbo.[vestiging];
