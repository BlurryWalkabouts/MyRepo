
-- DROP PROCEDURE [dbo].[ReportBins]
CREATE PROCEDURE [dbo].[ReportBins] 

	@ReportBins nvarchar(max)
AS

BEGIN

-- Selectie op [MDS].[mdm].[usp_ReportBins]

SELECT
     	  [Code]
		  ,[Name]
		  ,[ChangeTrackingMask]
		  ,[ReportIncAgeBinLow]
		  ,[ReportIncAgeBinMid]
		  ,[ReportIncAgeBinHigh]
		  ,[ReportIncDurationBinLow]
		  ,[ReportIncDurationBinMid]
		  ,[ReportIncDurationBinHigh]
		  ,[ReportIncSLVerstoringen]
		  ,[ReportIncSLAanvragenVragen]
		  ,[ReportIncSLVerstoringBinLow]
		  ,[ReportIncSLVerstoringBinMid]
		  ,[ReportIncSLVerstoringBinHigh]
		  ,[ReportIncSLAanvragenVragenBinLow]
		  ,[ReportIncSLAanvragenVragenBinMid]
		  ,[ReportIncSLAanvragenVragenBinHigh]
  FROM [Dim].[ReportBins]
  WHERE Code = @ReportBins


/******************************************************
-- test
exec OGDW_Metadata.etl.LoadDimReportBins
select * from [$(OGDW)].dim.ReportBins
exec dbo.usp_ReportBins 1
**************************************************/

  end

------------------------------------------------------------------------------------------------------------------------
-- move ReportBins to OGDW



/********************************************************************************************************/

-- DROP TABLE  [dim].[ReportInfo]
-- OGDW tabel maken 

CREATE TABLE [Dim].ReportInfo(
	[Code] int NOT NULL,
	[Name] [nvarchar](250) NULL,
	[ReportName] [nvarchar](100) NULL,
	[LandingPage] [nvarchar](4000) NULL,
	[PDF] [nvarchar](4000) NULL,
	[Word] [nvarchar](4000) NULL,
	[Logo] [nvarchar](100) NULL,
	[EnableIncidents] tinyint NULL,
	[EnableChanges] tinyint NULL,
	[EnableCalls] tinyint NULL,
	CONSTRAINT [PK_ReportInfo] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]



/********************************************************************************************************/
-- SPROC om tabel uit te lezzen 

/****** Object:  StoredProcedure [dbo].[usp_ReportInfo]   Script Date: 7-9-2016 15:18:04 ******/


SET ANSI_NULLS ON