
CREATE PROCEDURE [dbo].[ColourSchema] 

	@ColourSchema AS nvarchar(max)

AS

BEGIN

-- Selectie op [MDS].[mdm].[ColourSchema]
SELECT 
      [Code]
      ,[Name]
      ,[Omschrijving]
      ,[Inc_Aangemeld1]
      ,[Inc_Aangemeld2]
      ,[Inc_Aangemeld3]
      ,[Inc_Aangemeld4]
      ,[Inc_Afgemeld1]
      ,[Inc_Afgemeld2]
      ,[Inc_Afgemeld3]
      ,[Inc_Afgemeld4]
      ,[Inc_Openstaand1]
      ,[Inc_Openstaand2]
      ,[Inc_Openstaand3]
      ,[Inc_Openstaand4]
      ,[Inc_Gereed1]
      ,[Inc_workload]
      ,[Cha_Aangemeld1]
      ,[Cha_Aangemeld2]
      ,[Cha_Aangemeld3]
      ,[Cha_Aangemeld4]
      ,[Cha_Afgemeld1]
      ,[Cha_Afgemeld2]
      ,[Cha_Afgemeld3]
      ,[Cha_Afgemeld4]
      ,[Cha_Openstaand1]
      ,[Cha_Openstaand2]
      ,[Cha_Openstaand3]
      ,[Cha_Openstaand4]
      ,[Cha_Gereed1]
      ,[Cha_workload]
      ,[Line_target]
      ,[Line_mean]
      ,[DataLabel]
      ,[DataLabelPerc]
      ,[Call_Opgenomen]
      ,[Call_Opgenomen1]
      ,[Call_Opgenomen2]
      ,[Call_Opgenomen3]
      ,[Call_Opgenomen4]
      ,[Call_Nietopgenomen]
      ,[Call_workload]
  FROM [Dim].[ColourSchema]
  WHERE code = @ColourSchema


/******************************************************
-- test
exec OGDW_Metadata.etl.LoadDimColourSchema
select * from dim.colourschema
exec dbo.usp_ColourSchema 1
**************************************************/

  end