CREATE TABLE [Security].[AzureGroupMapping]
(
	[ID]                INT              IDENTITY (1, 1),
	[AzureGroupID]      INT              NOT NULL,
	[CustomerKey]       INT              NULL,
	[OperatorGroupKey]  INT              NULL,
	[OperatorGroupGuid] UNIQUEIDENTIFIER NULL,
	CONSTRAINT [PK_AzureGroupMapping] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO