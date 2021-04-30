

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [Dim].[vwIncidentTypeSTD] as

SELECT 
	[Name]
FROM Dim.IncidentTypeSTD

  /*
 Changed from MDS to Batch 

 SELECT 
      distinct      
      [TranslatedValue] as Name

  FROM [MDS].[mdm].[SourceTranslation]
  where TranslatedColumnName = 'IncidentTypeSTD'
 */
