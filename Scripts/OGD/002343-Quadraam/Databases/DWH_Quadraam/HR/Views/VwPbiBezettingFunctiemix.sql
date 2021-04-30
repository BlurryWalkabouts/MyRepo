CREATE VIEW [HR].[VwPbiBezettingFunctiemix]
AS

SELECT
	DatumKey = d.DatumKey
	, KostenplaatsKey = f.KostenplaatsKey
	, DienstverbandKey = fs.DienstverbandKey
	, SchaalCode = CASE fs.SchaalCode WHEN '12G' THEN 'LD' WHEN '11G' THEN 'LC' ELSE fs.SchaalCode END
	, Trede = fs.Trede
	, IsBovenschools = fs.IsBovenschools
	, FTE_Bruto = fte.FTE_Bruto
FROM
	Dim.Datum d
	LEFT OUTER JOIN Dim.FunctieSchaal fs ON d.Datum BETWEEN BegindatumSalaris AND EinddatumSalaris
	LEFT OUTER JOIN Dim.Functie f ON fs.DienstverbandKey = f.DienstverbandKey
	LEFT OUTER JOIN Fact.FTE fte ON d.MaandKey = fte.MaandKey AND f.FunctieKey = fte.FunctieKey
	LEFT OUTER JOIN Dim.Dienstverband dv ON dv.DienstverbandKey = fs.DienstverbandKey
WHERE 1=1
	AND fte.FTE_Bruto IS NOT NULL
	AND f.KostenplaatsKey <> -1
	AND dv.IsVervanging = 0
	AND fs.SchaalCode IN ('LB','LC','LD','12G','11G')
	AND fte.FTE_Bruto > 0