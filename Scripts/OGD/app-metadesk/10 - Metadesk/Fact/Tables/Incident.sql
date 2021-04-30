CREATE TABLE [Fact].[Incident](
	[Incident_Id] [int] IDENTITY(1,1) NOT NULL,
	[Guid] [uniqueidentifier] NOT NULL,
	[CustomerKey] [int] NULL,
	[CustomerNumber] [nvarchar](10) NOT NULL,
	[IncidentNumber] [nvarchar](255) NULL,
	[IncidentDescription] [nvarchar](255) NULL,
	[OperatorGroupKey] [int] NULL,
	[OperatorGroupGuid] [uniqueidentifier] NULL,
	[OperatorGroup] [nvarchar](255) NULL,
	[OperatorGuid] [uniqueidentifier] NULL,
	[Operator] [nvarchar](255) NULL,
	[CreationDate] [datetime2](7) NULL,
	[IncidentDate] [datetime2](7) NULL,
	[CompletionDate] [datetime2](7) NULL,
	[ClosureDate] [datetime2](7) NULL,
	[ChangeDate] [datetime2](7) NULL,
	[StatusID] [int] NOT NULL,
	[Status] [nvarchar](255) NULL,
	[StatusSTD] [nvarchar](100) NULL,
	[IncidentType] [nvarchar](255) NULL,
	[IncidentTypeSTD] [nvarchar](100) NULL,
	[SlaTargetDate] [datetime2](7) NULL,
	[Url]  AS ('incident?action=lookup&lookup=naam&lookupValue='+[IncidentNumber]),
	[SlaAchievedFlag]  AS (CONVERT([bit],case when [SlaTargetDate]>CONVERT([datetime],switchoffset(sysutcdatetime(),datepart(tzoffset,(sysutcdatetime() AT TIME ZONE 'Central European Standard Time')))) then (1) else (0) end)),
 CONSTRAINT [PK_Incident] PRIMARY KEY CLUSTERED 
(
	[Incident_Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO