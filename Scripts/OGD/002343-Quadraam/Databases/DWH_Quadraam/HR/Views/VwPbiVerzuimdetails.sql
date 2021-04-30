CREATE VIEW [HR].[VwPbiVerzuimdetails]
AS

SELECT DISTINCT
	DatumKey = v.DatumKey
	, MedewerkerKey = dv.MedewerkerKey
	, Aanvangsdatum_Verzuim = v.Aanvangsdatum_Verzuim
	, Hersteldatum_verzuim = v.Hersteldatum_verzuim
	, DagNaam = d2.DagNaam
	, Begindatum_Ziektetijdvak = v.Begindatum_Ziektetijdvak
	, Einddatum_Ziektetijdvak = v.Einddatum_Ziektetijdvak
	, VerzuimType = v.VerzuimType
	, IsDoorlopendVerzuim = CAST(v.IsDoorlopendVerzuim AS int)
	, IsVangnetregeling = v.IsVangnetregeling
	, AfwezigheidPercentage = v.AfwezigheidPercentage
	, Row# = CASE WHEN v.VerzuimType IS NULL THEN 0 ELSE DENSE_RANK() OVER (PARTITION BY dv.MedewerkerKey ORDER BY v.Begindatum_Ziektetijdvak, v.Einddatum_Ziektetijdvak) - 1 END
	, IsZiekmelding = CASE WHEN v.Aanvangsdatum_Verzuim = v.Begindatum_Ziektetijdvak AND d1.Datum = v.Aanvangsdatum_Verzuim THEN 1 ELSE 0 END
FROM
	Fact.Verzuim v
	LEFT OUTER JOIN Dim.Datum d1 ON v.DatumKey = d1.DatumKey
	LEFT OUTER JOIN Dim.Datum d2 ON v.Aanvangsdatum_Verzuim = d2.Datum
	LEFT OUTER JOIN Dim.Dienstverband dv ON v.DienstverbandKey = dv.DienstverbandKey
WHERE 1=1
	AND v.Aanvangsdatum_Verzuim IS NOT NULL