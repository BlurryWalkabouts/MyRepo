


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Dim].[vwStatusSTD] as

SELECT 
      [Name]
FROM Dim.StatusSTD

/*

 Changed from MDS to Batch 

 SELECT 
      distinct      
      [TranslatedValue] as Name
  FROM [MDS].[mdm].[SourceTranslation]
  where TranslatedColumnName = 'StatusSTD'
  */



