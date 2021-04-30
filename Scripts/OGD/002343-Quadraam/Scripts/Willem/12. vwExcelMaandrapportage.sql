SELECT
	gbkmut.ID
	, grtbk.Class_02
	, jaar = year(gbkmut.docdate)
	, gbkmut.bkjrcode
	, gbkmut.reknr
	, gbkmut.docdate
	, gbkmut.datum
	, gbkmut.periode
	, periode2 = MONTH(gbkmut.docdate)
	, gbkmut.oms25
	, gbkmut.bdr_hfl
	, afdeling = LEFT(gbkmut.kstplcode,3)
	, gbkmut.kstplcode
	, gbkmut.kstdrcode
	, gbkmut.aantal
	, gbkmut.koers
	, gbkmut.bdr_val
	, gbkmut.docdate
	, gbkmut.bud_vers
	, gbkmut.TransactionType
	, gbkmut.Rate
	, gbkmut.AmountCentral
	, gbkmut.transtype
	, gbkmut.transsubtype
FROM
	[001].dbo.gbkmut
	INNER JOIN [001].dbo.grtbk ON gbkmut.reknr = grtbk.reknr
WHERE 1=1
	AND gbkmut.transtype <> 'V'
	AND gbkmut.bkjrcode >= 2016

SELECT
	*
FROM
	DWH_Quadraam.Fin.VwExcelMaandrapportage
WHERE 1=1
	AND transtype <> 'V'
	AND bkjrcode >= 2016
	AND bkjrcode <= 2018