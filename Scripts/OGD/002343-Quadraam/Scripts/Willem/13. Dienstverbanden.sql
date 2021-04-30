SELECT
	Medewerker
	, Dienstverband
	, Begindatum_contract
	, Einddatum_contract
	, *
FROM
	Staging_Quadraam.Afas.DWH_HR_Dienstverbanden d
WHERE 1=1
	AND Medewerker = 93966
--	AND Dienstverband = 2
ORDER BY
	d.Dienstverband
	, d.Begindatum_contract

SELECT
	Medewerker
	, Dienstverband
	, Begindatum_functie
	, Einddatum_functie
	, *
FROM
	Staging_Quadraam.Afas.DWH_HR_Functie f
WHERE 1=1
	AND Medewerker = 93966
--	AND Dienstverband = 2
ORDER BY
	f.Dienstverband
	, f.Begindatum_functie

SELECT
	*
FROM
	Staging_Quadraam.Afas.DWH_HR_Formatieverdeling f
WHERE 1=1
	AND Medewerker = 93966
--	AND Dienstverband = 2
ORDER BY
	f.DV
	, f.Begindatum