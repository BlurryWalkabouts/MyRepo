/*
-- Find invalid BU-Team combinations
SELECT DISTINCT
	 E.FirstName
	,E.LastNamePrefixes
	,E.LastName
	,E.ContractType
	,E.BusinessUnit_Name
	,E.Team_Name
FROM [HumanResources].[Employee] E
LEFT JOIN [mdm].[BU_Team] BUT ON (BUT.BusinessUnit_Code = E.BusinessUnit_Code AND BUT.Team_Code = E.Team_Code AND ValidationStatus = 'Validation Succeeded')
WHERE BUT.[Name] IS NULL
ORDER BY BusinessUnit_Name, Team_Name
*/

/*
-- List Functions by Mapping
SELECT DISTINCT
	 E.BusinessUnit_Name
	,E.Team_Name
	,E.Function_Name
	,Excel_Team = CONCAT(BUT.[Name], ' {', BUT.[Code], '}')
	,Excel_Function = CONCAT(E.Function_Name, ' {', E.Function_Code, '}')
	,F.[IsArchived_Name]
FROM [HumanResources].[Employee] E
LEFT JOIN [mdm].[BU_Team] BUT ON (BUT.BusinessUnit_Code = E.BusinessUnit_Code AND BUT.Team_Code = E.Team_Code AND ValidationStatus = 'Validation Succeeded')
LEFT JOIN [mdm].[OGD_Functions] F ON (F.Code = E.Function_Code AND F.[State] = 'Active' AND F.LastChgDateTime > SYSUTCDATETIME())
WHERE 
	1=1
	AND BUT.[Name] IS NOT NULL 
	AND F.[Name] IS NOT NULL
ORDER BY 
	E.BusinessUnit_Name, 
	E.Team_Name, 
	E.[Function_Name]
*/
-- Proper BU/Team/Function Mapping
SELECT DISTINCT
	   [InitialPath] = MTF.[Name]
	  ,E.[Name]
      ,E.[Code]
      ,E.[FirstName]
      ,E.[LastName]
      ,E.[LastNamePrefixes]
      ,E.[Initals]
      ,E.[PostalCode]
      ,E.[City]
      ,[Gender] = CASE WHEN E.[Gender] = 1 THEN 'M {1}' ELSE 'F {2}' END
      ,E.[YearOfBirth]
      ,E.[EmailAddress]
      ,E.[TelephoneNumber]
	  ,[OrganizationPath_Code] = CONCAT(BUT.[Name], ' {' , BUT.[Code], '}')
	  ,[OrganizationPath_Name] = COALESCE(MTF.[Name], '')
	  ,[Function] = COALESCE(CONCAT(E.[Function_Name], ' {', E.[Function_Code], '}'), '')
	  ,[FunctionLevel] = CASE WHEN E.FunctionLevel_Name IS NULL THEN '' ELSE CONCAT(E.[FunctionLevel_Name], ' {', E.[FunctionLevel_Code], '}') END
	  ,[Manager] = CASE WHEN E.[Manager_Name] IS NOT NULL THEN CONCAT(E.[Manager_Name], ' {', E.[Manager_Code], '}') ELSE '' END
	  ,[CareerAdvisor] = CASE WHEN E.CareerAdvisor_Name IS NOT NULL THEN CONCAT(E.[CareerAdvisor_Name], ' {', E.[CareerAdvisor_Code], '}') ELSE '' END
      ,E.[CareerAdvisorDateNextAppointment]
      ,E.[EmployeeAvailability]
      ,E.[ContractAvailability]
      ,E.[ContractAvailabilityPercentage]
	  ,E.[ContractDateStart]
	  ,E.[ContractDateEnd]
      ,E.[ContractType]
      ,[EmployeeHasInternalAssignment_Code] = CASE WHEN E.[EmployeeHasInternalAssignment_Code] = 0 THEN 'False {0}' ELSE 'True {1}' END
      ,[ContractHasReturnedSignedCopy_Code] = CASE WHEN E.[ContractHasReturnedSignedCopy_Code] = 0 THEN 'False {0}' ELSE 'True {1}' END
      ,E.[ContractAdvisedExternalHourlyRate]
      ,[CarHasDriversLicense_Code] = CASE WHEN E.[CarHasDriversLicense_Code] = 0 THEN 'False {0}' ELSE 'True {1}' END
      ,[CarIsOwner] = CASE WHEN E.[CarIsOwner_Code] = 0 THEN 'False {0}' ELSE 'True {1}' END
      ,[IsArchived] = CASE WHEN E.[IsArchived_Code] = 0 THEN 'False {0}' ELSE 'True {1}' END
      ,E.[Hash]
      ,LIFTLastModifiedBy = CONCAT(E.[LIFTLastModifiedBy_Name], ' {', E.[LIFTLastModifiedBy_Code], '}')
	  ,DateLastModified
FROM [HumanResources].[Contractor] E
LEFT JOIN [mdm].[BU_Team] BUT ON (BUT.BusinessUnit_Name = E.BusinessUnit_Name AND BUT.Team_Name = E.Team_Name AND BUT.ValidationStatus = 'Validation Succeeded')
LEFT JOIN [mdm].[OGD_Mapp_Team_Func] MTF ON (MTF.[Team_Code] = BUT.[Code] AND MTF.[Function_Name] = E.[Function_Name] AND MTF.ValidationStatus = 'Validation Succeeded')
WHERE 
	1=1
	--AND BUT.[Name] IS NOT NULL
	--AND MTF.[Name] IS NOT NULL
ORDER BY 
	OrganizationPath_Name,
	E.[FirstName],
	E.[LastName]