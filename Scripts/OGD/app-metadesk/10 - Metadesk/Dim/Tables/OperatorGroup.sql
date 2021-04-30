CREATE TABLE [Dim].[OperatorGroup](
	[OperatorGroupKey] [int] IDENTITY(1,1) NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[CustomerNumber] [nvarchar](10) NOT NULL,
	[OperatorGroupGuid] [uniqueidentifier] NOT NULL,
	[OperatorGroup] [nvarchar](255) NOT NULL,
	[OperatorGroupSTD] [nvarchar](100) NULL,
	[ChangeDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_OperatorGroup] PRIMARY KEY CLUSTERED 
(
	[OperatorGroupKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
UNIQUE NONCLUSTERED 
(
	[CustomerKey] ASC,
	[OperatorGroupGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO