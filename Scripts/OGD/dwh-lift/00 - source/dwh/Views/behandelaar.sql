CREATE VIEW dwh.[behandelaar] AS
SELECT
    [unid],
    [archief],
    [rang],
    [gebruikerid],
    [afascode],
    [afkorting] = null,
    [signer]
FROM dbo.[behandelaar];
