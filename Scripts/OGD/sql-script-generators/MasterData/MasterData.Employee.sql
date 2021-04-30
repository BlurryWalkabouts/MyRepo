/****** Object:  View [OCD].[Delta_Employee]    Script Date: 12/9/2018 5:15:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [MasterData].[Employee] AS
SELECT [EmployeeNumber] = E.[Name]
      ,[FirstName]
      ,[LastName]
      ,[LastNamePrefixes]
      ,[LastNameWithPrefixes]
      ,[DisplayName]
      ,[Gender] = [Gender_Name]
      ,[UserPrincipalName]
      ,[EmailAddress]
      ,[SIPAddress]
      ,[TelephoneNumber]
      ,[Office]
      ,[OrganizationPath] = [OrganizationPath_Name]
	  ,[FunctionPath] = MTF.[Name]
      ,[BusinessUnit] = [BusinessUnit_Name]
      ,[Team] = E.[Team_Name]
      ,[Function] = E.[Function_Name]
      ,[FunctionLevel_Name]
      ,[Manager] = [Manager_Name]
	  ,[ManagerUserPrincipalName]
      ,[ContractDateStart]
      ,[ContractType]
      ,[EmployeeHasInternalAssignment] = [EmployeeHasInternalAssignment_Code]
      ,[ActiveDirectoryIsEnabled] = [ActiveDirectoryIsEnabled_Code]
	  ,[DateLastModified] = E.EnterDateTime
  FROM [mdm].[OCD_Employee] E
  INNER JOIN [mdm].[OGD_Mapp_Team_Func] MTF ON (MTF.Function_Code = E.Function_Code AND MTF.Team_Code = E.OrganizationPath_Code)
  WHERE 
	E.[ValidationStatus] = 'Validation Succeeded'
	AND E.[Name] != '000000'
GO


SELECT SYSUTCDATETIME(), GETDATE(), CONVERT(DATE, SWITCHOFFSET(SYSUTCDATETIME(), DATEPART(TZOFFSET, SYSUTCDATETIME() AT TIME ZONE 'Central European Standard Time'))), (SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time')


ALTER VIEW [MasterData].[EmployeeDelta] AS
	SELECT *
	FROM [MasterData].[Employee]
	WHERE DATEDIFF(MINUTE, [DateLastModified], (SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time')) <= 15
GO


CREATE VIEW [MasterData].[EmployeeJson] AS (
	SELECT	
		[JSON_Object] = (SELECT * FROM [MasterData].[Employee] DE WHERE E.EmployeeNumber = DE.EmployeeNumber FOR JSON PATH)
	FROM 
		[MasterData].[Employee] E
)
GO