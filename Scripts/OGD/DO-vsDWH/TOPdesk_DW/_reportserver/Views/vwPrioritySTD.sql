

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Dim].[vwPrioritySTD] as

SELECT 
	[Name]
FROM Dim.PrioritySTD

/*
 Changed from MDS to Batch 

SELECT 
      distinct      
      [TranslatedValue] as Name

  FROM [MDS].[mdm].[SourceTranslation]
  where TranslatedColumnName = 'PrioritySTD'
*/
