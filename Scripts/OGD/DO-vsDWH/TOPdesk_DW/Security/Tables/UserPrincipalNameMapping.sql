CREATE TABLE [Security].[UserPrincipalNameMapping]
(
	[ID]                  INT              IDENTITY (1, 1),
	[UserPrincipalNameID] INT              NOT NULL,
	[CustomerKey]         INT              NULL,
	[OperatorGroupKey]    INT              NULL,
	[OperatorGroupGuid]   UNIQUEIDENTIFIER NULL,
	CONSTRAINT [PK_UserPrincipalNameMapping] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO