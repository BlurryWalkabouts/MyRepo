CREATE TABLE [Security].[AzureGroupMapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[azureGroupID] [int] NOT NULL,
	[customerKey] [int] NULL,
	[operatorGroupKey] [int] NULL,
	[operatorGroupGuid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AzureGroupMapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO