CREATE VIEW dwh.[activiteitgroep] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [status],
    [archiefid],
    [archiefdatum],
    [naam],
    [uurprijs],
    [nultarief]
FROM dbo.[activiteitgroep];
