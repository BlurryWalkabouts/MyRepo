-- EXTRAOPZ6WER = HR Adviseur
-- EXTRATEAMEMPL = Team
-- TBL01EXVELD003 = Leidinggevende
-- TBL01EXVELD004 = Business Unit
-- TBL01EXVELD005 = Functie

;With FirstPass AS (
	select distinct
		 [BusinessUnit] = COALESCE(but1.BusinessUnitName, 'Lookup Error')
		,[Team] = COALESCE(but1.TeamName, 'Lookup Error')
		,[Function] = COALESCE(functie, vo1.tekst, vo2.tekst)
		--,w.[ValidFrom]
		--,w.[ValidTo]
		,ValidFrom = MIN(w.ValidFrom)
		,ValidTo = MAX(w.ValidTo)
	FROM 
		dbo.werknemer FOR SYSTEM_TIME ALL w
		LEFT JOIN tmp.HistoricBusinessUnitTeam but1 ON (
			-- BU/Team matchcases
			(
				-- First case: Only BU matches (Pre 2018)
				(w.exveld004 = but1.unidBu AND w.extra_team IS NULL)
				-- Second case: Unid match for BU and Team
				-- This is the match we generally want
				OR (w.exveld004 = but1.unidBu AND w.extra_team = but1.unidTeam)
				-- Third case: Spelling match due to a bug in ETL that didn't bring across the unids
				OR (w.business_unit = but1.BusinessUnitName AND w.extra_team = but1.TeamName)
			)
			-- Always specify time periode
			AND w.ValidFrom >= but1.ValidFrom AND w.ValidTo <= but1.validTo
		)
		LEFT JOIN dbo.vrijopzoek FOR SYSTEM_TIME ALL vo1 ON (vo1.unid = w.exveld005 AND w.ValidFrom >= vo1.ValidFrom AND w.ValidTo <= vo1.validTo)
		LEFT JOIN dbo.vrijopzoek FOR SYSTEM_TIME ALL vo2 ON (vo2.tekst = w.functie AND w.ValidFrom >= vo2.ValidFrom AND w.ValidTo <= vo2.validTo)
	WHERE COALESCE(functie, vo1.tekst, vo2.tekst) IS NOT NULL
	GROUP BY 
		 COALESCE(but1.BusinessUnitName, 'Lookup Error')
		,COALESCE(but1.TeamName, 'Lookup Error')
		,COALESCE(functie, vo1.tekst, vo2.tekst)
)
SELECT
	 [BusinessUnit]
	,[Team]
	,[Function]
	--,[ValidFrom] = CASE WHEN (LAG(ValidTo, 1, 0) OVER (Partition by BusinessUnit, Team, [Function] ORDER BY ValidFrom, ValidTo)) != ValidFrom THEN (LAG(ValidTo, 1, 0) OVER (Partition by BusinessUnit, Team, [Function] ORDER BY ValidFrom, ValidTo)) ELSE ValidFrom END
	,[ValidFrom]
	--,[ValidPrevious] = (LAG(ValidTo) OVER (Partition by BusinessUnit, Team, [Function] ORDER BY ValidFrom, ValidTo))
	,[ValidTo]
FROM FirstPass AS FP
ORDER BY BusinessUnit, Team, [Function], ValidFrom, ValidTo