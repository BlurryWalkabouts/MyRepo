CREATE VIEW dwh.[contractsoort] AS
SELECT
    [unid],
    [archief],
    [rang],
    [tekst],
    [onbepaald],
    null as [afkorting]
FROM dbo.[contractsoort];
