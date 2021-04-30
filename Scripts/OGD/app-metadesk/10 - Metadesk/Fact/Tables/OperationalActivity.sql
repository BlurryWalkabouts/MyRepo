CREATE TABLE [Fact].[OperationalActivity](
	[OperationalActivity_Id] [int] IDENTITY(1,1) NOT NULL,
	[Guid] [uniqueidentifier] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[CustomerNumber] [nvarchar](10) NOT NULL,
	[OperationalSeriesNumber] [nvarchar](255) NULL,
	[OperationalSeriesName] [nvarchar](255) NULL,
	[OperationalActivityNumber] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[DetailedDescription] [nvarchar](max) NULL,
	[OperatorGroupKey] [int] NULL,
	[OperatorGroupGuid] [uniqueidentifier] NULL,
	[OperatorGroup] [nvarchar](255) NULL,
	[OperatorKey] [int] NULL,
	[OperatorGuid] [uniqueidentifier] NULL,
	[Operator] [nvarchar](255) NULL,
	[StatusID] [int] NULL,
	[Status] [nvarchar](255) NULL,
	[CreationDate] [datetime2](7) NULL,
	[ChangeDate] [datetime2](7) NULL,
	[PlannedStartDate] [datetime2](7) NULL,
	[PlannedCompletionDate] [datetime2](7) NULL,
	[CompletionDate] [datetime2](7) NULL,
	[Completed] [bit] NULL,
	[Skipped] [bit] NULL,
	[Url]  AS ('operationsmanagementactivity?action=lookup&lookup=nummer&lookupValue='+[OperationalActivityNumber]),
	[TargetDateAchievedFlag]  AS (CONVERT([bit],case when [PlannedCompletionDate]>CONVERT([datetime],switchoffset(sysutcdatetime(),datepart(tzoffset,(sysutcdatetime() AT TIME ZONE 'Central European Standard Time')))) then (1) else (0) end)),
PRIMARY KEY CLUSTERED 
(
	[OperationalActivity_Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO