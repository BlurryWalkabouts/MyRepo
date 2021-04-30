CREATE TABLE [Security].[UserPrincipalNameSuffixMapping](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userPrincipalNameSuffixID] [int] NOT NULL,
	[customerKey] [int] NULL,
	[operatorGroupKey] [int] NULL,
	[operatorGroupGuid] [uniqueidentifier] NULL,
 CONSTRAINT [PK_UserPrincipalNameSuffixMapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO