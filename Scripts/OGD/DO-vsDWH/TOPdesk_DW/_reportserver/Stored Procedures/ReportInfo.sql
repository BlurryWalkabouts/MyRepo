
-- DROP PROCEDURE [dbo].[ReportInfo]
CREATE PROCEDURE [dbo].[ReportInfo] 

	@ReportInfo int
AS

BEGIN

-- Selectie op [MDS].[mdm].[usp_ReportBins]

SELECT
		Name
		,Code
		,ReportName
		,LandingPage
		,PDF
		,Word
		,Logo
		,EnableIncidents
		,EnableChanges
		,EnableCalls
	FROM [Dim].[ReportInfo]
	WHERE Code = @ReportInfo

/******************************************************
-- test
exec OGDW_Metadata.etl.LoadDimReportInfo
select * from [$(OGDW)].dim.ReportInfo
exec dbo.usp_ReportInfo 2
**************************************************/


  end

------------------------------------------------------------------------------------------------------------------------

-- move ReportLabels to OGDW


/********************************************************************************************************/

-- DROP TABLE  [dim].[ReportLabels]
-- tabel maken 

CREATE TABLE [Dim].[ReportLabels](
	[Code] int NOT NULL,
	[Name] [nvarchar](250) NULL,
	[Language] [nvarchar](250) NULL,
	[Locale] [nvarchar](100) NULL,
	[Translation] [nvarchar](1000) NULL

	CONSTRAINT [PK_ReportLabels] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]



/********************************************************************************************************/
-- SPROC om tabel uit te lezzen 

/****** Object:  StoredProcedure [dbo].[ReportLabels]   Script Date: 7-9-2016 15:18:04 ******/



SET ANSI_NULLS ON