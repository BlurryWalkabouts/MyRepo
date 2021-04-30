CREATE TABLE [Fact].[Change](
	[Change_Id] [int] IDENTITY(1,1) NOT NULL,
	[Guid] [uniqueidentifier] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[CustomerNumber] [nvarchar](10) NOT NULL,
	[ChangeNumber] [nvarchar](255) NOT NULL,
	[DescriptionBrief] [nvarchar](255) NULL,
	[CoordinatorGroupKey] [int] NULL,
	[CoordinatorGuid] [uniqueidentifier] NULL,
	[Coordinator] [nvarchar](255) NULL,
	[RequestAuthorizationOperatorKey] [int] NULL,
	[RequestAuthorizationOperatorGuid] [uniqueidentifier] NULL,
	[RequestAuthorizationOperator] [nvarchar](255) NULL,
	[ProgressAuthorizationOperatorKey] [int] NULL,
	[ProgressAuthorizationOperatorGuid] [uniqueidentifier] NULL,
	[ProgressAuthorizationOperator] [nvarchar](255) NULL,
	[EvaluationAuthorizationOperatorKey] [int] NULL,
	[EvaluationAuthorizationOperatorGuid] [uniqueidentifier] NULL,
	[EvaluationAuthorizationOperator] [nvarchar](255) NULL,
	[CreationDate] [datetime2](7) NULL,
	[CompletionDate] [datetime2](7) NULL,
	[ChangeDate] [datetime2](7) NULL,
	[Status] [INT] NULL,
	[TicketStatus] [nvarchar](255) NULL,
	[CurrentPhase] [int] NULL,
	[ChangeType] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[TypeSTD] [nvarchar](100) NULL,
	[Url]  AS ('newchange?action=lookup&lookup=number&lookupValue='+[ChangeNumber]),
	[TargetDate] [datetime2](7) NULL,
	[TargetDateAchievedFlag]  AS (CONVERT([bit],case when [TargetDate]>CONVERT([datetime],switchoffset(sysutcdatetime(),datepart(tzoffset,(sysutcdatetime() AT TIME ZONE 'Central European Standard Time')))) then (1) else (0) end)),
 CONSTRAINT [PK_Change] PRIMARY KEY CLUSTERED 
(
	[Change_Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO