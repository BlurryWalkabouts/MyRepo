CREATE VIEW dwh.[invoiced_invoiceplanning] AS
SELECT
	[unid],
	[dataanmk],
	[datwijzig],
	[invoiceid],
	[price_ex_vat],
	[vatid],
	[invoice_planning_id],
	[booking_date],
	[correctedid]
FROM dbo.invoiced_invoiceplanning;