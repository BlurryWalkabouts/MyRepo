CREATE TABLE [Security].[UserPrincipalNameSuffixMapping]
(
	[ID]                        INT              IDENTITY (1, 1),
	[UserPrincipalNameSuffixID] INT              NOT NULL,
	[CustomerKey]               INT              NULL,
	[OperatorGroupKey]          INT              NULL,
	[OperatorGroupGuid]         UNIQUEIDENTIFIER NULL,
	CONSTRAINT [PK_UserPrincipalNameSuffixMapping] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO