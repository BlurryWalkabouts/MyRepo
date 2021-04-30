-- EXTRAOPZ6WER = HR Adviseur
-- EXTRATEAMEMPL = Team
-- TBL01EXVELD003 = Leidinggevende
-- TBL01EXVELD004 = Business Unit
-- TBL01EXVELD005 = Functie
-------------
/*
	   [Name]
      ,[Code]
      ,[FirstName]
      ,[LastName]
      ,[LastNamePrefixes]
      ,[Initials]
      ,[PostalCode]
      ,[City]
      ,[Gender_Code]
      ,[YearOfBirth]
      ,[EmailAddress]
      ,[TelephoneNumber]
      ,[BusinessUnit_Code]
      ,[BusinessUnit_Name]
      ,[Team_Code]
      ,[Team_Name]
      ,[Function_Code]
      ,[Function_Name]
      ,[FunctionLevel_Code]
      ,[FunctionLevel_Name]
      ,[Manager_Code]
	  ,[Manager_Name]
      ,[CareerAdvisor_Code]
	  ,[CareerAdvisor_Name]
      ,[CareerAdvisorDateNextAppointment]
      ,[EmployeeAvailability]
      ,[ContractAvailability]
      ,[ContractAvailabilityPercentage]
      ,[ContractDateStart]
      ,[ContractDateEnd]
      ,[ContractType]
      ,[EmployeeHasInternalAssignment_Code]
      ,[ContractHasReturnedSignedCopy_Code]
	  ,[ContractAdvisedExternalHourlyRate]
      ,[CarHasDriversLicense_Code]
      ,[CarIsOwner_Code]
      ,[Hash]
      ,[LIFTLastModifiedBy_Code]
      ,[LIFTLastModifiedBy_Name]
      ,[LIFTLastModifiedBy_ID]
*/
-- Medewerkers
--CREATE VIEW MasterData.Employee AS 
;WITH R AS (
select distinct
	 -- Name and Code are required fields in MDS
	 [Name] = CASE WHEN w.persnr = '' THEN w.pmwnr ELSE w.persnr END
	,[Code] = w.[unid]
	 -- Name identifiers
	 -- Trimming everything due to LIFT not doing it for us.
	,[FirstName] = LTRIM(RTRIM(w.rnaam))
	,[LastName] = LTRIM(RTRIM(w.anaam))
	,[LastNamePrefixes] = COALESCE(LTRIM(RTRIM(w.tussen)), '')
	,[Initals] = LTRIM(RTRIM(w.inits))
	 -- Office Identifiers
	,[PostalCode] = LEFT(ltrim(w.postcode1), 4)
	,[City] = COALESCE(w.plaats1, '[Not Available]')
	 -- Other Personal Identifiers
	 -- 1 = M, 2 = F. This is straight from LIFT
	,[Gender] = w.geslacht
	 -- Per agreement with Manager HR, CIO: Only year
	,[YearOfBirth] = COALESCE(DATEPART(YEAR, w.geboren), 1900)
	 -- Contact information
	,[EmailAddress] = CASE WHEN w.email NOT LIKE '%@ogd.nl' THEN '' ELSE w.email END
	,[TelephoneNumber] = CASE WHEN w.tel1 NOT LIKE '088%' OR w.tel1 IS NULL THEN '' ELSE REPLACE(w.tel1, ' ', '') END
	 -- Organization Identifier
	,[BusinessUnit_Code] = COALESCE(BU.unid, '00000000-0000-0000-0000-000000000000')
	,[BusinessUnit_Name] = COALESCE(BU.tekst, '[Not Available]')
	,[Team_Code] = COALESCE(BUT.unid, '00000000-0000-0000-0000-000000000000')
	,[Team_Name] = COALESCE(BUT.tekst, '[Not Available]')
	,[Function_Code] = COALESCE( F.unid, '00000000-0000-0000-0000-000000000000')
	,[Function_Name] = COALESCE(F.tekst, wc.functie, 'Automatiseringsmedewerker')
	,[FunctionLevel_Code] = COALESCE(S.unid, '00000000-0000-0000-0000-000000000000')
	,[FunctionLevel_Name] = COALESCE(S.tekst, '[Not Available]')
	 -- People responsible for employee
	,[Manager_Code] = CASE WHEN M.tekst = 'Geen' THEN NULL ELSE M1.unid END
	,[Manager_Name] = COALESCE(M.tekst, '[Not Available]')
	,[CareerAdvisor_Code] = COALESCE(HR1.unid, '00000000-0000-0000-0000-000000000000')
	,[CareerAdvisor_Name] = CASE WHEN HR1.unid IS NULL THEN '[Not Available]' ELSE COALESCE(HR.tekst, '[Not Available]') END
	 -- Various
	,[CareerAdvisorDateNextAppointment] = CASE WHEN vo5.[tekst] LIKE '[0-9][0-9]%' THEN DATEFROMPARTS(ex02.[tekst], LEFT(vo5.[tekst],2), 1) ELSE DATEFROMPARTS(1900, 1, 1) END
	 -- Contract Information
	,[EmployeeAvailability] = COALESCE(w.stdbeschikbaarheid, 0)
	,[ContractAvailability] = 40 * COALESCE(wc.procent, 0) / 100
	,[ContractAvailabilityPercentage] = COALESCE(wc.procent, 0)
	,[ContractDateStart] = COALESCE(wc.startdatum, DATEFROMPARTS(1900, 1, 1))
	,[ContractDateEnd] = COALESCE(wc.einddatum, CASE WHEN wc.startdatum IS NOT NULL THEN '9999-12-31 23:59:59.9999999' ELSE DATEFROMPARTS(1900, 1, 1) END)
	,[ContractType] = COALESCE(wc.contractsoort, '[Not Available]')
	,[EmployeeHasInternalAssignment_Code] = CASE WHEN IA.employeeid IS NULL THEN 0 ELSE 1 END
	,[ContractHasReturnedSignedCopy_Code] = COALESCE(wc.retour, 0)
	,[ContractAdvisedExternalHourlyRate] = COALESCE(wc. uurtarief, 0)
	,[CarHasDriversLicense_Code] = w.rijbewijs
	,[CarIsOwner_Code] = w.[auto]
	,[IsArchived_Code] = CASE WHEN w.status < 0 THEN 1 ELSE 0 END
FROM
	dbo.werknemer w
	LEFT JOIN dbo.vrijopzoek BU ON (BU.unid = W.exveld004)
	LEFT JOIN dbo.vrijopzoek BUT ON (BUT.unid = W.extra_team)
	LEFT JOIN dbo.vrijopzoek F ON (F.unid = w.exveld005)
	LEFT JOIN dbo.vrijopzoek S ON (S.unid = w.extra_niveau)
	LEFT JOIN dbo.vrijopzoek M ON (M.unid = w.exveld003)
	    -- jaartal volgend gesprek
    LEFT JOIN dbo.[vrijopzoek] ex02 ON ex02.[Kaartcode] = 'TBL01EXVELD002' AND ex02.[unid] = w.[exveld002]
        --AND ex02.[archief] > 0
    -- maandtal volgend gesprek
    LEFT JOIN dbo.[vrijopzoek] vo5 ON vo5.[Kaartcode] = 'EXTRAOPZ5WER' AND vo5.[unid] = w.[extraopz5]
        --AND vo5.[archief] > 0
	LEFT JOIN dbo.werknemer M1 ON (M1.Status > 0 AND M.tekst = CAST((((M1.rnaam+' ')+case when M1.tussen<>'' then M1.tussen+' ' else '' end)+M1.anaam) AS varchar(50)) COLLATE SQL_Latin1_General_Cp1251_CI_AS)
	LEFT JOIN dbo.vrijopzoek HR ON (HR.unid = w.extraopz6)
	LEFT JOIN dbo.werknemer HR1 ON (HR1.Status > 0 AND HR.tekst = CAST((((HR1.rnaam+' ')+case when HR1.tussen<>'' then HR1.tussen+' ' else '' end)+HR1.anaam) AS varchar(100)) COLLATE SQL_Latin1_General_Cp1251_CI_AS)
	LEFT JOIN (
		SELECT
				werknemerid
			,status
			,contractsoort = cs.[tekst]
			,uurtarief
			,procent
			,startdatum
			,einddatum
			,functie
			,retour
		FROM dbo.wcontract wc
		INNER JOIN dbo.[contractsoort] cs ON cs.[unid] = wc.[contractsoortid]
	) wc ON (
		-- Sometimes a text match is needed.
		(wc.werknemerid = w.unid)
		AND (wc.status > 0 AND wc.contractsoort IS NOT NULL)
	)
	LEFT JOIN (
		SELECT DISTINCT
			[employeeid]
		FROM dbo.voordracht v
				INNER JOIN [dbo].[project] p ON (p.unid = v.projectid AND projectnr LIKE '001013.%' AND projectnr NOT LIKE '001013.00[1,3,5].0[0-4]')
		) IA ON (IA.employeeid = w.unid)
	WHERE 
		w.status in (3)
		AND (w.persnr != '' OR w.pmwnr != '')
)
select 
	 R.*
	,[Hash] = HASHBYTES('SHA2_256', (select R.* from (values(null))foo(bar) for xml auto))
	,G.[LIFTLastModifiedBy_Code]
	,G.[LIFTLastModifiedBy_Name]
	,G.[LIFTLastModifiedBy_Desc]
from R
LEFT JOIN (
	select 
		 [Code] = e.unid
		,[LIFTLastModifiedBy_Code] = w.unid
		,[LIFTLastModifiedBy_Name] = w.persnr
		,[LIFTLastModifiedBy_Desc] = g.naam
	from dbo.gebruiker g
	inner join dbo.werknemer w ON (g.employeeid = w.unid)
	inner join dbo.werknemer e ON (e.uidwijzig = g.unid)
	where w.persnr != ''
) G ON (G.code = R.code)
where LastName = 'Schure'
--where businessunit != '[Not Available]' AND Team != '[Not Available]'
--where [function] = 'Teamleider SSD Helvetios'
--where lastname LIKE 'Dus%'
--where team = 'mt'
--where businessunit = 'Oproepkrachten'
--where managerunid = '00000000-0000-0000-0000-000000000000' and manager IN ('Geen', '[Not available]') and contracttype = 'Oproep'
--order by ModifiedByName, [businessunit], [team], [function]


/*
ALTER USER [sa_MasterDataReader] WITH PASSWORD='xqj8932r8g67fbivnlbogypq2983r7129412471256285!313131241!!341242425@#$@%345tf43t4!';
GO
CREATE ROLE [MasterDataReader];
GO
ALTER ROLE [MasterDataReader] ADD MEMBER [sa_MasterDataReader];
GO
GRANT SELECT ON SCHEMA::MasterData TO [MasterDataReader];
GO
*/