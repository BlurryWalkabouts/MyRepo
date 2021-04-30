CREATE VIEW dwh.[aanvraag] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [status],
    [archiefid],
    [archiefdatum],
    [attentieid],
    [attentiemelding],
    [projectid],
    [aanvraagnr],
    [slagingspercentage],
    [interessecijferid],
    [interessefaseid],
    [bewaakttot],
    [afkorting] =  null,
    [projectleadid],
    [amount_quoted],
    [datacceptatie],
    [is_additional_request]
FROM dbo.[aanvraag];
