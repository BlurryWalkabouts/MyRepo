CREATE VIEW [HR].[VwPbiVerzuimfrequentie]
AS

-- CTE maken van verzuimfrequentietabel met alleen mdws met een verzuimrecords
WITH Verzuimfreq_CTE AS
(
SELECT DISTINCT
	DatumKey = v.DatumKey
	, KostenplaatsKey = f.KostenplaatsKey
	, MedewerkerKey = f.MedewerkerKey
	, IsZiekmelding = CASE WHEN v.Aanvangsdatum_Verzuim = v.Begindatum_Ziektetijdvak AND d.Datum = v.Aanvangsdatum_Verzuim THEN 1 ELSE 0 END
	, IsZiek = CASE WHEN v.Aanvangsdatum_Verzuim IS NOT NULL THEN 1 ELSE 0 END
	, IsNulverzuim = CASE WHEN v.Aanvangsdatum_Verzuim IS NULL THEN 1 ELSE 0 END
FROM
	Fact.Verzuim v
	LEFT OUTER JOIN Dim.Datum d ON v.DatumKey = d.DatumKey
	LEFT OUTER JOIN Dim.Functie f ON v.DienstverbandKey = f.DienstverbandKey AND d.Datum BETWEEN f.BegindatumFunctie AND f.EinddatumFunctie
	LEFT OUTER JOIN Dim.Dienstverband dv ON f.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Dim.Medewerker m ON dv.MedewerkerKey = m.MedewerkerKey
	LEFT OUTER JOIN Dim.Kostenplaats kp ON f.KostenplaatsKey = kp.KostenplaatsKey
WHERE 1=1
	AND dv.FTE_Dienstverband > 0
)

SELECT DISTINCT
	DatumKey = d.DatumKey
	, KostenplaatsKey = f.KostenplaatsKey
	, MedewerkerKey = f.MedewerkerKey
	, IsZiekmelding = CASE WHEN IsZiekmelding IS NULL THEN 0 ELSE IsZiekmelding END
	, IsZiek	= CASE WHEN IsZiek IS NULL THEN 0 ELSE IsZiek END	
	, IsNulverzuim = CASE WHEN IsZiek = 1 THEN 0 ELSE 1 END
FROM
	Dim.Datum d
	LEFT OUTER JOIN Dim.Functie f ON d.Datum BETWEEN f.BegindatumFunctie AND f.EinddatumFunctie
	LEFT OUTER JOIN Verzuimfreq_CTE v ON d.DatumKey = v.DatumKey AND f.KostenplaatsKey = v.KostenplaatsKey AND f.MedewerkerKey = v.MedewerkerKey
	LEFT OUTER JOIN Dim.Medewerker mdw ON f.MedewerkerKey = mdw.MedewerkerKey -- verwijderen (nu even als check)
WHERE 1=1
	AND JaarNum IN (2015,2016,2017,2018) -- Nog flexibel maken obv huidige datum