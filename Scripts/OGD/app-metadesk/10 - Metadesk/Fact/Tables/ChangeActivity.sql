CREATE TABLE [Fact].[ChangeActivity](
	[ChangeActivity_Id] [int] IDENTITY(1,1) NOT NULL,
	[Guid] [uniqueidentifier] NOT NULL,
	[ChangeKey] [int] NOT NULL,
	[ChangeGuid] [uniqueidentifier] NOT NULL,
	[ChangeNumber] [nvarchar](255) NOT NULL,
	[CustomerKey] [int] NULL,
	[CustomerNumber] [nvarchar](10) NOT NULL,
	[ActivityNumber] [nvarchar](255) NULL,
	[ChangeBriefDescription] [nvarchar](255) NULL,
	[BriefDescription] [nvarchar](255) NULL,
	[OperatorGroupKey] [int] NULL,
	[OperatorGroupGuid] [uniqueidentifier] NULL,
	[OperatorGroup] [nvarchar](255) NULL,
	[OperatorKey] [int] NULL,
	[OperatorGuid] [uniqueidentifier] NULL,
	[Operator] [nvarchar](255) NULL,
	[CreationDate] [datetime2](7) NULL,
	[ClosureDate] [datetime2](7) NULL,
	[PlannedFinalDate] [datetime2](7) NULL,
	[ChangeDate] [datetime2](7) NULL,
	[Status] [nvarchar](255) NULL,
	[Started] [bit] NULL,
	[Skipped] [bit] NULL,
	[Rejected] [bit] NULL,
	[Resolved] [bit] NULL,
	[MayStart] [bit] NULL,
	[ParentUrl]  AS ('newchange?action=lookup&lookup=number&lookupValue='+[ChangeNumber]),
	[Url]  AS ('changeactivity?action=lookup&lookup=number&lookupValue='+[ActivityNumber]),
	[TargetDateAchievedFlag]  AS (CONVERT([bit],case when [PlannedFinalDate]>CONVERT([datetime],switchoffset(sysutcdatetime(),datepart(tzoffset,(sysutcdatetime() AT TIME ZONE 'Central European Standard Time')))) then (1) else (0) end)),
 CONSTRAINT [PK_ChangeActivity] PRIMARY KEY CLUSTERED 
(
	[ChangeActivity_Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO