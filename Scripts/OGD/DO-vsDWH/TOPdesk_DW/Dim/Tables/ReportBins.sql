CREATE TABLE [Dim].[ReportBins]
(
	[Code]                              INT            NOT NULL,
	[Name]                              NVARCHAR (250) NULL,
	[ChangeTrackingMask]                INT            NULL,
	[ReportIncAgeBinLow]                INT            NULL,
	[ReportIncAgeBinMid]                INT            NULL,
	[ReportIncAgeBinHigh]               INT            NULL,
	[ReportIncDurationBinLow]           INT            NULL,
	[ReportIncDurationBinMid]           INT            NULL,
	[ReportIncDurationBinHigh]          INT            NULL,
	[ReportIncSLVerstoringen]           INT            NULL,
	[ReportIncSLAanvragenVragen]        INT            NULL,
	[ReportIncSLVerstoringBinLow]       INT            NULL,
	[ReportIncSLVerstoringBinMid]       INT            NULL,
	[ReportIncSLVerstoringBinHigh]      INT            NULL,
	[ReportIncSLAanvragenVragenBinLow]  INT            NULL,
	[ReportIncSLAanvragenVragenBinMid]  INT            NULL,
	[ReportIncSLAanvragenVragenBinHigh] INT            NULL,
	CONSTRAINT [PK_ReportBins] PRIMARY KEY CLUSTERED ([Code] ASC)
)