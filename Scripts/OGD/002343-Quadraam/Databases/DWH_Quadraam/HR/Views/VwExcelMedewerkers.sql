CREATE VIEW [HR].[VwExcelMedewerkers]
AS

SELECT DISTINCT
	DatumKey = d.DatumKey
	, MedewerkerKey = m.MedewerkerKey
	, KostenplaatsKey = k.KostenplaatsKey
--	, FunctieKey = f.FunctieKey
	, Leeftijd = FLOOR(DATEDIFF(DD, m.Geboortedatum, d.Datum) / 365.25)
	, Leeftijdscategorie = CASE 
			WHEN FLOOR(DATEDIFF(DD, m.Geboortedatum, d.Datum) / 365.25) BETWEEN '10' AND '19' THEN '10<20'
			WHEN FLOOR(DATEDIFF(DD, m.Geboortedatum, d.Datum) / 365.25) BETWEEN '20' AND '29' THEN '20<30'
			WHEN FLOOR(DATEDIFF(DD, m.Geboortedatum, d.Datum) / 365.25) BETWEEN '30' AND '39' THEN '30<40'
			WHEN FLOOR(DATEDIFF(DD, m.Geboortedatum, d.Datum) / 365.25) BETWEEN '40' AND '49' THEN '40<50'
			WHEN FLOOR(DATEDIFF(DD, m.Geboortedatum, d.Datum) / 365.25) BETWEEN '50' AND '59' THEN '50<60'
			WHEN FLOOR(DATEDIFF(DD, m.Geboortedatum, d.Datum) / 365.25) BETWEEN '60' AND '69' THEN '60<70'
			ELSE '0'
		END
	, [Dienstjaren Quadraam] = ROUND(DATEDIFF(YY, m.DatumInDienst, d.Datum),0)
	, Jarig = CASE WHEN FORMAT(m.Geboortedatum, 'ddMM') = FORMAT(GETDATE(), 'ddMM') THEN 'Ja' ELSE 'Nee' END
	, Geboortemaand = DATEPART(MM, m.Geboortedatum)
	, Geboortedag = DATEPART(DD, m.Geboortedatum)
	, Verjaardag = DATEADD(YY, (DATEDIFF(YY, m.Geboortedatum, GETDATE())), m.Geboortedatum)
	, DatumGeb = m.Geboortedatum
	, Datum = d.Datum
FROM
	Dim.Datum d
	LEFT OUTER JOIN Dim.Functie f ON d.Datum BETWEEN f.BegindatumFunctie AND f.EinddatumFunctie
	LEFT OUTER JOIN Dim.Medewerker m ON f.MedewerkerKey = m.MedewerkerKey
	LEFT OUTER JOIN Dim.Kostenplaats k ON f.KostenplaatsKey = k.KostenplaatsKey
WHERE 1=1
	AND d.Datum > '2016-12-31'
	AND d.Datum <= GETDATE()
	AND m.MedewerkerKey <> -1