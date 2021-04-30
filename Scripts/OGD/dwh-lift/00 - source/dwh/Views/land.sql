CREATE VIEW dwh.[land] AS
SELECT
    [unid],
    [archief],
    [rang],
    [landnaam],
    [exactcode],
    [afascode],
    [kingcode],
    [pclengte],
    [nummereerst],
    [nummerverplicht],
    [voertaalid],
    [adrescontrole],
    [afkorting] = null
FROM dbo.[land];
