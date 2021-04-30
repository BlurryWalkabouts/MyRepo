CREATE TABLE [Fact].[Problem](
	[Problem_Id] [int] IDENTITY(1,1) NOT NULL,
	[Guid] [uniqueidentifier] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[CustomerNumber] [nvarchar](10) NOT NULL,
	[ProblemNumber] [nvarchar](255) NOT NULL,
	[ProblemDescription] [nvarchar](255) NULL,
	[OperatorGroupKey] [int] NULL,
	[OperatorGroupGuid] [uniqueidentifier] NULL,
	[OperatorGroup] [nvarchar](255) NULL,
	[OperatorKey] [int] NULL,
	[OperatorGuid] [uniqueidentifier] NULL,
	[Operator] [nvarchar](255) NULL,
	[CreationDate] [datetime2](7) NULL,
	[ProblemDate] [datetime2](7) NULL,
	[CompletionDate] [datetime2](7) NULL,
	[ClosureDate] [datetime2](7) NULL,
	[ChangeDate] [datetime2](7) NULL,
	[ProblemType] [nvarchar](255) NULL,
	[StatusID] [int] NULL,
	[Status] [nvarchar](255) NULL,
	[Url]  AS ('problem?action=lookup&lookup=naam&lookupValue={0}'+[ProblemNumber]),
	[TargetDate] [datetime2](7) NULL,
	[TargetDateAchievedFlag]  AS (CONVERT([bit],case when [TargetDate]>CONVERT([datetime],switchoffset(sysutcdatetime(),datepart(tzoffset,(sysutcdatetime() AT TIME ZONE 'Central European Standard Time')))) then (1) else (0) end)),
 CONSTRAINT [PK_Problem] PRIMARY KEY CLUSTERED 
(
	[Problem_Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO