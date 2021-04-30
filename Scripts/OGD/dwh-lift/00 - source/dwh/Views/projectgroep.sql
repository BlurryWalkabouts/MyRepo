CREATE VIEW dwh.[projectgroep] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [status],
    [klantid],
    [naam],
    [projectleiderid],
    [contactid],
    [projectgroepnr],
    [aanvraaggroepnr],
    [aanvraag_vnr],
    [project_vnr],
    [percentagegereed]
FROM dbo.[projectgroep];
