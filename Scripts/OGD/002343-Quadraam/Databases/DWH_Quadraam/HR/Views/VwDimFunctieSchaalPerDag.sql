CREATE VIEW [HR].[VwDimFunctieSchaalPerDag]
AS
SELECT 
	d.DatumKey
	, fs.[FunctieSchaalKey]
	, fs.[DienstverbandKey]
	, fs.[SchaalCode]
	, fs.[Trede]
	, fs.[IsBovenschools]
FROM Dim.Datum d
LEFT OUTER JOIN [Dim].[FunctieSchaal] fs ON

d.Datum >= CAST(fs.[BegindatumSalaris] AS DATE)
AND (CAST(fs.[EinddatumSalaris] AS DATE) >= d.Datum OR CAST(fs.[EinddatumSalaris] AS DATE) IS NULL)

WHERE d.Datum <= DATEADD(MONTH,2,GETDATE())
AND fs.FunctieSchaalKey <> -1