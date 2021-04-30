CREATE VIEW dwh.[taakvoordracht] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [status],
    [taakid],
    [type],
    [startdatum],
    [einddatum],
    [inkoopprijs],
    [werklast],
    [budget],
    [vrijvelda],
    [afkorting] = null,
    [employeeid]
FROM dbo.[taakvoordracht];
