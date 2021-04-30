CREATE VIEW dwh.[assignment_hour] AS
SELECT
    [unid],
    [dataanmk],
    [datwijzig],
    [uidaanmk],
    [uidwijzig],
    [datum],
    [verwerkt_factuur],
    [factuurid],
    [seen_by_invoice_id],
    [hourtypeid],
    [assignmentid],
    [seconds],
    [old_amount]
FROM dbo.[assignment_hour];
