CREATE TABLE [Security].[UserPrincipalNameMapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userPrincipalNameID] [int] NOT NULL,
	[customerKey] [int] NULL,
	[operatorGroupKey] [int] NULL,
	[operatorGroupGuid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_UserPrincipalNameMapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO