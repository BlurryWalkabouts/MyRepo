CREATE VIEW dwh.[invoice] AS 
SELECT	
	[unid],
	[dataanmk],
	[datwijzig],
	[motherprojectid],
	[debtorid],
	[contactpersonid],
	[start_span],
	[end_span],
	[document_date],
	[price_ex_vat],
	[invoicenr],
	[corrected_invoiceid],
	[specify_per_child_project],
	[payment_conditionid],
	[nr_of_intervals],
	[vat_price]
FROM dbo.[invoice];