CREATE TABLE [Dim].[Customer](
	[CustomerKey] [int] NOT NULL,
	[CustomerNumber] [nvarchar](10) NULL,
	[Fullname] [nvarchar](100) NULL,
	[TOPdeskUrl] [nvarchar](255) NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO