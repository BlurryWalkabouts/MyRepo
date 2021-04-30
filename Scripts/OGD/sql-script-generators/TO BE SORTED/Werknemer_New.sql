SELECT DISTINCT
	   W.unid
      ,[sollicitatie_aanleiding] = SA.tekst
      ,[gesolliciteerd_op_functie] = SF.tekst
      ,[rijbewijs]
      ,[auto]
      ,[persnr]
	  ,status
      ,[stdbeschikbaarheid]
      ,[vestigingid]
      ,[datumindienst]
      ,[hi_datumindienst]
      ,[datumuitdienst]
      ,[Datum_PotentieelWerknemer] = [datpotwn] -- Datum Potentieel Werknemer
      ,[Datum_StartDatumContract] = [datwn] -- Datum werknemer
	  ,UrenmanagerId
      ,[beschikbaar_vanaf]
	  ,[HR_ContactPersoon] = VO6.tekst
	  ,[Leidinggevende] = EX03.Tekst
	  ,exveld003
      ,[anaam]
      ,[rnaam]
      ,[tussen]
      ,[plaats1]
      ,[postcode1] = LEFT(postcode1, 4)
      ,[tel1] = CASE WHEN tel1 LIKE '088%' OR tel1 LIKE '+3188%' OR tel1 LIKE '+31 88%' THEN tel1 ELSE NULL END
	   ,[email] = CASE WHEN [email] NOT LIKE '%@ogd.nl' THEN NULL ELSE [email] END
	  ,[geboren] = DATEPART(YEAR, geboren)
	  ,W.ValidFrom
	  ,W.ValidTo
INTO dbo.werknemer_new
FROM 
(
	SELECT *, ValidFrom, ValidTo
	FROM [Repl_LIFT_001013_OGD].dbo.[werknemer_old]
	FOR SYSTEM_TIME ALL
	--where anaam = 'Schure'
) W
OUTER APPLY (
	SELECT TOP 1
		* 
	FROM
		dbo.vrijopzoek 
	FOR SYSTEM_TIME ALL
	WHERE
		1=1
		AND Kaartcode = 'TBL01EXVELD003' 
		AND unid = W.exveld003
		AND ValidTo >= W.ValidTo
	ORDER BY ValidTo ASC
) EX03
OUTER APPLY (
	SELECT TOP 1
		* 
	FROM
		dbo.vrijopzoek 
	WHERE
		1=1
		AND Kaartcode = 'EXTRAOPZ6WER' 
		AND unid = W.extraopz6
		AND unid = W.exveld003
		AND ValidTo >= W.ValidTo
	ORDER BY ValidTo ASC
) VO6
LEFT JOIN dbo.sollicitatie_aanleiding SA ON (SA.unid = W.sollicitatie_aanleidingid)
LEFT JOIN dbo.functie SF ON (SF.unid = W.gesolliciteerd_op_functieid)
/*
LEFT JOIN dbo.vrijopzoek VO1 ON (VO1.Kaartcode = 'EXTRAOPZ1WER' AND VO1.unid = W.[extraopz1])
LEFT JOIN dbo.vrijopzoek VO2 ON (VO2.Kaartcode = 'EXTRAOPZ2WER' AND VO2.unid = W.[extraopz2])
LEFT JOIN dbo.vrijopzoek VO3 ON (VO3.Kaartcode = 'EXTRAOPZ3WER' AND VO3.unid = W.[extraopz3])
LEFT JOIN dbo.vrijopzoek VO4 ON (VO4.Kaartcode = 'EXTRAOPZ4WER' AND VO4.unid = W.[extraopz4])
LEFT JOIN dbo.vrijopzoek EX03 ON (EX03.Kaartcode = 'TBL01EXVELD003' AND EX03.unid = W.exveld003)
LEFT JOIN dbo.vrijopzoek VO6 ON (VO6.Kaartcode = 'EXTRAOPZ6WER' AND VO6.unid = W.[extraopz6])
LEFT JOIN dbo.sollicitatie_aanleiding SA ON (SA.unid = W.sollicitatie_aanleidingid)
LEFT JOIN dbo.functie SF ON (SF.unid = W.gesolliciteerd_op_functieid)
*/
--where W.unid = '8EC0DD91-C84F-4BA6-90EF-7C1E6166CCA6'
order by unid, ValidFrom


--select *, ValidFrom, ValidTo from dbo.vrijopzoek FOR SYSTEM_TIME ALL order by ValidFrom