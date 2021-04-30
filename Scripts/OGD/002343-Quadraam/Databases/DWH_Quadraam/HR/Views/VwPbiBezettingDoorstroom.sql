CREATE VIEW [HR].[VwPbiBezettingDoorstroom]
AS

SELECT DISTINCT
	MaandKey = fte.MaandKey
	, KostenplaatsKey = f.KostenplaatsKey
	, Dienstverband = dv.Dienstverband
	, BegindatumFunctie = f.BegindatumFunctie
	, EinddatumFunctie = f.EinddatumFunctie
	, MedewerkerCode = m.MedewerkerCode
	, MedewerkerNaam = m.MedewerkerNaam
	, KostenplaatsNaam = fte_vorig.KostenplaatsNaam
	, FTE_Instroom = fte.FTE_Bruto
	, IsDoorstroom = 1
FROM
	Fact.FTE fte
	LEFT OUTER JOIN Dim.Functie f ON fte.FunctieKey = f.FunctieKey
	LEFT OUTER JOIN Dim.Maand d ON fte.MaandKey = d.MaandKey
	LEFT OUTER JOIN Dim.Kostenplaats kp ON f.KostenplaatsKey = kp.KostenplaatsKey
	LEFT OUTER JOIN Dim.Dienstverband dv ON f.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Dim.Kostendrager kd ON f.KostendragerKey = kd.KostendragerKey
	LEFT OUTER JOIN Dim.Medewerker m ON f.MedewerkerKey = m.MedewerkerKey
	LEFT OUTER JOIN (
		SELECT
			MaandKeyLead
			, fte.MaandKey
			, kd.KostendragerKey
			, dv.IsUitbreiding
			, dv.IsHoofddienstverband
			, f.IsFunctie
			, MaandKey_Eind = d_eind.MaandKey
			, m.MedewerkerKey
			, f.KostenplaatsKey
			, kp.KostenplaatsNaam
			, fte.[FTE_Bruto]
		FROM
			Fact.FTE fte 
			LEFT OUTER JOIN Dim.Functie f ON fte.FunctieKey = f.FunctieKey
			LEFT OUTER JOIN Dim.Dienstverband dv ON f.DienstverbandKey = dv.DienstverbandKey
			LEFT OUTER JOIN Dim.Medewerker m ON f.MedewerkerKey = m.MedewerkerKey
			LEFT OUTER JOIN Dim.Kostenplaats kp ON f.KostenplaatsKey = kp.KostenplaatsKey
			LEFT OUTER JOIN Dim.Datum d_eind ON f.EinddatumFunctie = d_eind.Datum
			LEFT OUTER JOIN Dim.Kostendrager kd ON f.KostendragerKey = kd.KostendragerKey
			LEFT OUTER JOIN (SELECT MaandKey, MaandKeyLead = LEAD(MaandKey, 1, 0) OVER (ORDER BY MaandKey) FROM Dim.Maand) d ON fte.MaandKey = d.MaandKey
		) fte_vorig ON 1=1
			AND fte.MaandKey = fte_vorig.MaandKeyLead
			AND f.MedewerkerKey = fte_vorig.MedewerkerKey
			AND fte_vorig.MaandKey_Eind < fte.MaandKey
--			AND fte_vorig.KostendragerKey = f.KostendragerKey (case mdw 94272 werd onterecht niet meegeteld door deze filter)
			AND fte_vorig.IsHoofddienstverband = 1
			AND fte_vorig.IsUitbreiding = 0
--			AND fte_vorig.FTE_Bruto > 0 (case mdw 94272 werd onterecht niet meegeteld door deze filter)
			AND fte_vorig.IsFunctie = 1
WHERE 1=1
	AND f.KostenplaatsKey <> fte_vorig.KostenplaatsKey
	AND dv.IsHoofddienstverband = 1
	AND dv.IsUitbreiding = 0
	AND fte.[FTE_Bruto] > 0
	AND f.IsFunctie = 1