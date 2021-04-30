SELECT
	bkjrcode
	, docdate = YEAR(docdate)
	, datum = YEAR(datum)
FROM
	[001].dbo.gbkmut
WHERE 1=1
	AND bkjrcode <> YEAR(datum)

-- vwExcelMaandrapportage: bkjrcode = fd.JaarNum