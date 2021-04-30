SELECT DISTINCT 
  KostenplaatsCode = COALESCE(f.Kostenplaats, kp2.Nummer, kp1.kstplcode) 
  , KostenplaatsNaam = COALESCE(f.Brin_omschrijving, kp2.Omschrijving, kp1.oms25_0) 
  , BRIN_Nummer = f.Brin 
FROM 
  [001].dbo.kstpl kp1 
  FULL OUTER JOIN [Staging_Quadraam].Afas.DWH_FIN_Kostenplaatsen kp2 ON kp1.kstplcode = kp2.Nummer 
  LEFT OUTER JOIN [Staging_Quadraam].Afas.DWH_HR_Functie f ON kp1.kstplcode = f.Kostenplaats 

SELECT
	f.Kostenplaats
	, f.Omschrijving_kostenplaats
	, f.Brin
	, f.Brin_omschrijving
	, Aantal = COUNT(*)
FROM
	[Staging_Quadraam].Afas.DWH_HR_Functie f
GROUP BY
	f.Kostenplaats
	, f.Omschrijving_kostenplaats
	, f.Brin
	, f.Brin_omschrijving
ORDER BY
	f.Kostenplaats