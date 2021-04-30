CREATE VIEW dwh.[cursus] AS
SELECT
    [unid],
    [werknemerid],
    [naam],
    [leverancier],
    [cursusdatum],
    [einddatum],
    [dagen],
    [diploma],
    [price]
FROM dbo.[cursus];
