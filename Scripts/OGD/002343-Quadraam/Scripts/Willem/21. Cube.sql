SELECT
	Boekjaar
	, Periode
	, Aantal = COUNT(*)
FROM
	Staging_Quadraam.Afas.DWH_HR_Gebrokenfactor
WHERE 1=1
--	AND Medewerker = 94916
GROUP BY
	CUBE(Boekjaar,Periode)
ORDER BY
	Boekjaar
	, Periode