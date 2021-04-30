CREATE VIEW [HR].[VwPbiVerzuimduur]
AS

-- CTE maken van verzuimfrequentietabel met alleen mdws met een verzuimrecords
WITH Verzuimduur_CTE AS
(
SELECT DISTINCT
	DatumKey = v.DatumKey
	, KostenplaatsKey = f.KostenplaatsKey
	, MedewerkerKey = dv.MedewerkerKey
	, Verzuimduurklasse = v.Verzuimduurklasse
	, IsBetermelding = CASE WHEN v.Hersteldatum_verzuim >= v.Einddatum_Ziektetijdvak AND d.Datum = v.Hersteldatum_verzuim THEN 1 ELSE 0 END
	, DagenZiek = CASE WHEN v.Hersteldatum_verzuim >= v.Einddatum_Ziektetijdvak AND d.Datum = v.Hersteldatum_verzuim THEN DATEDIFF(DD,v.Aanvangsdatum_Verzuim,v.Hersteldatum_verzuim) + 1 ELSE 0 END
FROM
	Fact.Verzuim v
	LEFT OUTER JOIN Dim.Datum d ON v.DatumKey = d.DatumKey
	LEFT OUTER JOIN Dim.Dienstverband dv ON v.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Dim.Datum d2 ON v.Aanvangsdatum_Verzuim = d2.Datum
	LEFT OUTER JOIN Dim.Functie f ON dv.DienstverbandKey = f.DienstverbandKey -- AND d.Datum BETWEEN f.BegindatumFunctie AND f.EinddatumFunctie
WHERE 1=1
	AND dv.FTE_Dienstverband > 0
	AND v.Verzuimduurklasse <> '731_'
)

SELECT DISTINCT
	DatumKey = d.DatumKey
	, KostenplaatsKey = f.KostenplaatsKey
	, MedewerkerKey = f.MedewerkerKey
	, Verzuimduurklasse = CASE WHEN v.Verzuimduurklasse IS NULL THEN '0_0' ELSE v.Verzuimduurklasse END
	, IsBetermelding = CASE WHEN v.IsBetermelding IS NULL THEN 0 ELSE v.IsBetermelding END
	, DagenZiek = CASE WHEN v.DagenZiek IS NULL THEN 0 ELSE v.DagenZiek END
FROM
	Dim.Datum d
	LEFT OUTER JOIN Dim.Functie f ON d.Datum BETWEEN f.BegindatumFunctie AND f.EinddatumFunctie
	LEFT OUTER JOIN Verzuimduur_CTE v ON d.DatumKey = v.DatumKey AND f.MedewerkerKey = v.MedewerkerKey AND f.KostenplaatsKey = v.KostenplaatsKey
	LEFT OUTER JOIN Dim.Medewerker mdw ON f.MedewerkerKey = mdw.MedewerkerKey -- verwijderen (nu even als check)
WHERE 1=1
	AND JaarNum > 2013 -- Nog flexibel maken obv huidige datum