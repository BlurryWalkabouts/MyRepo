
-- DROP PROCEDURE [dbo].[ReportLabels]
CREATE PROCEDURE [dbo].[ReportLabels]

	@ReportLanguage nvarchar(max)
AS

BEGIN

-- Selectie op [MDS].[mdm].[ReportLabels]

	select
		Code
		,Name
		,[Language]
		,Locale
		,Translation

	from [Dim].[ReportLabels]
	where Locale = @ReportLanguage
  


/******************************************************
-- test
exec OGDW_Metadata.etl.LoadDimReportLabels
select * from ogdw.dim.ReportLabels
exec dbo.usp_ReportLabels 'nl'
**************************************************/

  end

------------------------------------------------------------------------------------------------------------------------

-- move ColourSchema to OGDW


/********************************************************************************************************/


-- OGDW tabel maken 

-- DROP TABLE  [dim].[ColourSchema]
CREATE TABLE [Dim].[ColourSchema](
--	[ColourSchemaKey] INT identity(1,1),
	[Code] int NOT NULL,
	[Name] [nvarchar](250) NULL,
	[Omschrijving] [nvarchar](100) NULL,
	[Inc_Aangemeld1] [nvarchar](100) NULL,
	[Inc_Aangemeld2] [nvarchar](100) NULL,
	[Inc_Aangemeld3] [nvarchar](100) NULL,
	[Inc_Aangemeld4] [nvarchar](100) NULL,
	[Inc_Afgemeld1] [nvarchar](100) NULL,
	[Inc_Afgemeld2] [nvarchar](100) NULL,
	[Inc_Afgemeld3] [nvarchar](100) NULL,
	[Inc_Afgemeld4] [nvarchar](100) NULL,
	[Inc_Openstaand1] [nvarchar](100) NULL,
	[Inc_Openstaand2] [nvarchar](100) NULL,
	[Inc_Openstaand3] [nvarchar](100) NULL,
	[Inc_Openstaand4] [nvarchar](100) NULL,
	[Inc_Gereed1] [nvarchar](100) NULL,
	[Inc_workload] [nvarchar](100) NULL,
	[Cha_Aangemeld1] [nvarchar](100) NULL,
	[Cha_Aangemeld2] [nvarchar](100) NULL,
	[Cha_Aangemeld3] [nvarchar](100) NULL,
	[Cha_Aangemeld4] [nvarchar](100) NULL,
	[Cha_Afgemeld1] [nvarchar](100) NULL,
	[Cha_Afgemeld2] [nvarchar](100) NULL,
	[Cha_Afgemeld3] [nvarchar](100) NULL,
	[Cha_Afgemeld4] [nvarchar](100) NULL,
	[Cha_Openstaand1] [nvarchar](100) NULL,
	[Cha_Openstaand2] [nvarchar](100) NULL,
	[Cha_Openstaand3] [nvarchar](100) NULL,
	[Cha_Openstaand4] [nvarchar](100) NULL,
	[Cha_Gereed1] [nvarchar](100) NULL,
	[Cha_workload] [nvarchar](100) NULL,
	[Line_target] [nvarchar](100) NULL,
	[Line_mean] [nvarchar](100) NULL,
	[DataLabel] [nvarchar](100) NULL,
	[DataLabelPerc] [nvarchar](100) NULL,
	[Call_Opgenomen] [nvarchar](100) NULL,
	[Call_Opgenomen1] [nvarchar](100) NULL,
	[Call_Opgenomen2] [nvarchar](100) NULL,
	[Call_Opgenomen3] [nvarchar](100) NULL,
	[Call_Opgenomen4] [nvarchar](100) NULL,
	[Call_Nietopgenomen] [nvarchar](100) NULL,
	[Call_workload] [nvarchar](100) NULL
	CONSTRAINT [PK_ColourSchema] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


/********************************************************************************************************/
-- SPROC om tabel uit te lezzen 

/****** Object:  StoredProcedure [dbo].[ColourSchema]    Script Date: 7-9-2016 15:18:04 ******/

SET ANSI_NULLS ON