


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Fact].[vwWorkforceResourcesPerDay] as
SELECT 
	   [Date]
      ,CustomerGroup
      ,[Hours]
FROM Fact.WorkforceResourcesPerDay

/*

 Changed from MDS to Batch 

 SELECT [Date]
      ,[CustomerGroup_Name] as CustomerGroup
      ,[Hours]
     FROM [MDS].[mdm].[WorkforceResources2]
*/

