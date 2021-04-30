USE [001]
GO

SELECT
	ID
	, kstplcode
	, afdeling = LEFT(kstplcode, 3)
	, oms25_0
FROM
	dbo.kstpl
WHERE 1=1
	AND bedrnr = '001'
	AND TRY_CAST(kstplcode AS int) IS NOT NULL

SELECT
	ID
	, kstdrcode
	, oms25_0
FROM
	dbo.kstdr
WHERE 1=1
	AND bedrnr = '001'

SELECT
	*
--	, Aantal = COUNT(*)
FROM
	dbo.gbkmut
WHERE 1=1
--	AND TRY_CAST(kstdrcode AS int) IS NULL
--	AND TRY_CAST(kstplcode AS int) IS NULL
--	AND kstdrcode NOT IN (SELECT DISTINCT kstdrcode FROM dbo.kstdr)
--	AND kstplcode NOT IN (SELECT DISTINCT kstplcode FROM dbo.kstpl)
	AND kstdrcode = ''
--GROUP BY
--	kstplcode
--	, kstdrcode
ORDER BY
	kstplcode