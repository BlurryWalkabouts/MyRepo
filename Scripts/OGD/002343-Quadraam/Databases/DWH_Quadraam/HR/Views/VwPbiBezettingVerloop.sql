CREATE VIEW [HR].[VwPbiBezettingVerloop]
AS 

SELECT DISTINCT
	DatumKey = d.DatumKey
	, KostenplaatsKey = f.KostenplaatsKey
	, DienstverbandKey = dv.DienstverbandKey
	, FTE_Dienstverband = dv.FTE_Dienstverband
	, MedewerkerKey = m.MedewerkerKey
	, MedewerkerNaam = m.MedewerkerNaam
	, MedewerkerCode = m.MedewerkerCode
	, Dienstverband = dv.Dienstverband
	, DatumInDienst = m.DatumInDienst
	, DatumUitDienst = m.DatumUitDienst
	, BegindatumContract = dv.BegindatumContract
	, EinddatumContract = dv.EinddatumContract
	, SchaalCode = fs.SchaalCode
	, Trede = fs.Trede
	, FTE_Instroom = fte.FTE_Bruto
	, FTE_Uitstroom = 0
	, IsInstroom = 1
	, IsUitstroom = 0
FROM
	Dim.Datum d
	LEFT OUTER JOIN Dim.Dienstverband dv ON d.Datum = dv.BegindatumContract
	LEFT OUTER JOIN Dim.Medewerker m ON dv.MedewerkerKey = m.MedewerkerKey
	LEFT OUTER JOIN Dim.Functie f ON dv.MedewerkerKey = f.MedewerkerKey AND m.DatumInDienst = f.BegindatumFunctie
	LEFT OUTER JOIN Fact.FTE fte On d.MaandKey = fte.MaandKey AND f.FunctieKey = fte.FunctieKey
	LEFT OUTER JOIN Dim.FunctieSchaal fs ON dv.DienstverbandKey = fs.DienstverbandKey AND d.Datum BETWEEN fs.BegindatumSalaris AND fs.EinddatumSalaris
WHERE 1=1
	AND d.DatumKey <> -1
	AND m.MedewerkerKey IS NOT NULL
	AND fte.FTE_Bruto > 0

UNION

SELECT DISTINCT
	DatumKey = d.DatumKey
	, KostenplaatsKey = f.KostenplaatsKey
	, DienstverbandKey = dv.DienstverbandKey
	, FTE_Dienstverband = dv.FTE_Dienstverband
	, MedewerkerKey = m.MedewerkerKey
	, MedewerkerNaam = m.MedewerkerNaam
	, MedewerkerCode = m.MedewerkerCode
	, Dienstverband = dv.Dienstverband
	, DatumInDienst = m.DatumInDienst
	, DatumUitDienst = m.DatumUitDienst
	, BegindatumContract = dv.BegindatumContract
	, EinddatumContract = dv.EinddatumContract
	, SchaalCode = fs.SchaalCode
	, Trede = fs.Trede
	, FTE_Instroom = 0
	, FTE_Uitstroom = dv.FTE_Dienstverband
	, IsInstroom = 0
	, IsUitstroom = 1
FROM
	Dim.Datum d
	LEFT OUTER JOIN Dim.Dienstverband dv ON d.Datum = dv.EinddatumContract
	LEFT OUTER JOIN Dim.Functie f ON f.MedewerkerKey = dv.MedewerkerKey AND dv.EinddatumContract = f.EinddatumFunctie
	LEFT OUTER JOIN Dim.Medewerker m ON dv.MedewerkerKey = m.MedewerkerKey AND d.Datum = m.DatumUitDienst
	LEFT OUTER JOIN Fact.FTE fte ON d.MaandKey = fte.MaandKey AND f.FunctieKey = fte.FunctieKey AND dv.DienstverbandKey = f.DienstverbandKey
	LEFT OUTER JOIN Dim.FunctieSchaal fs ON dv.DienstverbandKey = fs.DienstverbandKey AND d.Datum BETWEEN fs.BegindatumSalaris AND fs.EinddatumSalaris
WHERE 1=1
	AND d.DatumKey <> -1
	AND m.MedewerkerKey IS NOT NULL