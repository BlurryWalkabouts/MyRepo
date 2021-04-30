/****** Object:  View [MasterData].[Employee]    Script Date: 11/30/2018 11:24:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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
alter VIEW [MasterData].[Contractor] AS 
WITH R AS (
select distinct
	 -- Name and Code are required fields in MDS
	 [Name] = CASE WHEN w.status = 4 THEN w.pmwnr ELSE w.persnr END
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
	,[BusinessUnit_Code] = BU.unid
	,[BusinessUnit_Name] = BU.tekst
	,[Team_Code] = BUT.unid
	,[Team_Name] = BUT.tekst
	,[Function_Code] = F.unid
	,[Function_Name] = F.tekst
	,[FunctionLevel_Code] = NULL
	,[FunctionLevel_Name] = NULL
	 -- People responsible for employee
	,[Manager_Code] = CASE WHEN M.tekst = 'Geen' THEN NULL ELSE M1.unid END
	,[Manager_Name] = M.tekst
	,[CareerAdvisor_Code] = NULL
	,[CareerAdvisor_Name] = NULL
	 -- Various
	,[CareerAdvisorDateNextAppointment] = DATEFROMPARTS(1900, 1, 1)
	 -- Contract Information
	,[EmployeeAvailability] = 40
	,[ContractAvailability] = 40 * COALESCE(100, 0) / 100
	,[ContractAvailabilityPercentage] = 100
	,[ContractDateStart] = W.regeling3van
	,[ContractDateEnd] = W.regeling3tot
	,[ContractType] = 'Contractor'
	,[EmployeeHasInternalAssignment_Code] = CASE WHEN IA.employeeid IS NULL THEN 0 ELSE 1 END
	,[ContractHasReturnedSignedCopy_Code] = 1
	,[ContractAdvisedExternalHourlyRate] = 0
	,[CarHasDriversLicense_Code] = w.rijbewijs
	,[CarIsOwner_Code] = w.[auto]
	,[IsArchived_Code] = CASE WHEN w.status < 0 THEN 1 ELSE 0 END
FROM
	dbo.werknemer w
	LEFT JOIN dbo.vrijopzoek BU ON (BU.unid = W.pmwopz4)
	LEFT JOIN dbo.vrijopzoek BUT ON (BUT.unid = W.pmwopz3)
	LEFT JOIN dbo.vrijopzoek F ON (F.unid = w.pmwopz1)
	LEFT JOIN dbo.vrijopzoek M ON (M.unid = w.pmwopz2)
        --AND vo5.[archief] > 0
	LEFT JOIN dbo.werknemer M1 ON (M1.Status > 0 AND M.tekst = CAST((((M1.rnaam+' ')+case when M1.tussen<>'' then M1.tussen+' ' else '' end)+M1.anaam) AS varchar(50)) COLLATE SQL_Latin1_General_Cp1251_CI_AS)
	LEFT JOIN (
		SELECT DISTINCT
			[employeeid]
		FROM dbo.voordracht v
				INNER JOIN [dbo].[project] p ON (p.unid = v.projectid AND projectnr LIKE '001013.%' AND projectnr NOT LIKE '001013.00[1,3,5].0[0-4]')
		) IA ON (IA.employeeid = w.unid)
	WHERE 
		w.status in (4)
		AND (w.persnr != '' OR w.pmwnr != '')
		AND w.email LIKE '%@ogd.nl' 
)
select 
	 R.*
	,[Hash] = HASHBYTES('SHA2_256', (select R.* from (values(null))foo(bar) for xml auto))
	,G.[LIFTLastModifiedBy_Code]
	,G.[LIFTLastModifiedBy_Name]
	,G.[LIFTLastModifiedBy_Desc]
	,G.DateLastModified
from R
LEFT JOIN (
	select 
		 [Code] = e.unid
		,[LIFTLastModifiedBy_Code] = w.unid
		,[LIFTLastModifiedBy_Name] = w.persnr
		,[LIFTLastModifiedBy_Desc] = g.naam
		,[DateLastModified] = e.datwijzig
	from dbo.gebruiker g
	inner join dbo.werknemer w ON (g.employeeid = w.unid)
	inner join dbo.werknemer e ON (e.uidwijzig = g.unid)
	where w.persnr != ''
) G ON (G.code = R.code)
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
GO

--select * from dbo.werknemer where vnaam = 'Edwin' and anaam = 'Schouwenaar'


