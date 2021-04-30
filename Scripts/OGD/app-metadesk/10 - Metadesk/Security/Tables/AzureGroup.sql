CREATE TABLE [Security].[AzureGroup](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[guid] [uniqueidentifier] NULL,
	[name] [nvarchar](255) NOT NULL,
	[roleName] [nvarchar](255) NULL,
	[IsMember]  AS (is_member([RoleName])),
 CONSTRAINT [PK_AzureGroup] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO