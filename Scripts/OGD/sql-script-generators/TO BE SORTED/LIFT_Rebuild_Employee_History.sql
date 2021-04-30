;WITH FirstPass AS (
	select
		 rnaam
		,anaam
		,persnr
		,w.unid
		,BusinessUnit = COALESCE(Business_Unit, but1.BusinessUnitName)
		,Team = COALESCE(Extra_Team, but1.TeamName)
		,Functie = COALESCE(functie, vo1.tekst, vo2.tekst, 'Automatiseringsmedewerker')
		,HR = COALESCE(HR_Contactpersoon, hr.tekst, '[Unknown]')
		,Manager = COALESCE(Leidinggevende, mgr.tekst, '[Unknown]')
		,w.ValidFrom
		,w.ValidTo
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
			-- Always specify time period
			AND w.ValidFrom >= but1.ValidFrom AND w.ValidTo <= but1.validTo
		)
		LEFT JOIN dbo.vrijopzoek vo1 ON (vo1.unid = w.exveld005)
		LEFT JOIN dbo.vrijopzoek vo2 ON (vo2.tekst = w.functie)
		LEFT JOIN dbo.vrijopzoek hr ON (hr.unid = w.extraopz6)
		LEFT JOIN dbo.vrijopzoek FOR SYSTEM_TIME ALL mgr ON (mgr.unid = w.exveld003)
	WHERE anaam IN('Schure', 'Hulst', 'Zwaan')
)
SELECT DISTINCT
	 rnaam
	,anaam
	,persnr
	,BusinessUnit = COALESCE(BusinessUnit, LAG(BusinessUnit) OVER (PARTITION BY unid ORDER BY ValidFrom))
	,Team = COALESCE(Team, LAG(Team) OVER (PARTITION BY unid ORDER BY ValidFrom))
	,Functie
	,HR
	,Manager
	,ValidFrom
	,ValidTo
FROM 
	FirstPass
ORDER BY persnr, ValidFrom