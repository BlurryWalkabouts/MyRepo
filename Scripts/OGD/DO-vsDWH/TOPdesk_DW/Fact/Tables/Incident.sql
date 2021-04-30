CREATE TABLE [Fact].[Incident]
(
	[Incident_Id]                 INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[SourceDatabaseKey]           INT            NOT NULL,
	[AuditDWKey]                  INT            NOT NULL,
	[CustomerKey]                 INT            NOT NULL,
	[CallerKey]                   INT            NOT NULL,
	[OperatorGroupKey]            INT            NOT NULL,
	[ObjectKey]                   INT            NOT NULL,
	[DurationActual]              BIGINT         NULL,
	[DurationAdjusted]            BIGINT         NULL,
	[Category]                    NVARCHAR (255) NULL,
	[ConfigurationID]             NVARCHAR (255) NULL,
	[CardChangedBy]               NVARCHAR (255) NULL,
	[ChangeDate]                  DATE           NULL,
	[ChangeTime]                  TIME (0)       NULL,
	[ClosureDate]                 DATE           NULL,
	[ClosureTime]                 TIME (0)       NULL,
	[Closed]                      BIT            NULL,
	[CompletionDate]              DATE           NULL,
	[CompletionTime]              TIME (0)       NULL,
	[Completed]                   BIT            NULL,
	[CardCreatedBy]               NVARCHAR (255) NULL,
	[CreationDate]                DATE           NULL,
	[CreationTime]                TIME (0)       NULL,
	[CustomerName]                NVARCHAR (255) NULL,
	[CustomerAbbreviation]        NVARCHAR (100) NULL,
	[IncidentDescription]         NVARCHAR (255) NULL,
	[DurationOnHold]              BIGINT         NULL,
	[Duration]                    NVARCHAR (255) NULL,
	[EntryType]                   NVARCHAR (255) NULL,
	[EntryTypeSTD]                NVARCHAR (100) NULL,
	[ExternalNumber]              NVARCHAR (255) NULL,
	[OnHold]                      BIT            NULL,
	[IsMajorIncident]             BIT            NULL,
	[Impact]                      NVARCHAR (255) NULL,
	[IncidentDate]                DATE           NULL,
	[IncidentTime]                TIME (0)       NULL,
	[Line]                        NVARCHAR (255) NULL,
	[MajorIncident]               NVARCHAR (255) NULL,
	[IncidentNumber]              NVARCHAR (255) NULL,
	[OnHoldDate]                  DATE           NULL,
	[OnHoldTime]                  TIME (0)       NULL,
	[ObjectID]                    NVARCHAR (255) NULL,
	[Priority]                    NVARCHAR (255) NULL,
	[PrioritySTD]                 NVARCHAR (100) NULL,
	[Sla]                         NVARCHAR (255) NULL,
	[SlaContract]                 NVARCHAR (255) NULL,
	[StandardSolution]            NVARCHAR (255) NULL,
	[Status]                      NVARCHAR (255) NULL,
	[StatusSTD]                   NVARCHAR (100) NULL,
	[SlaTargetDate]               DATE           NULL,
	[SlaTargetTime]               TIME (0)       NULL,
	[Subcategory]                 NVARCHAR (255) NULL,
	[Supplier]                    NVARCHAR (255) NULL,
	[ServiceWindow]               NVARCHAR (255) NULL,
	[TargetDate]                  DATE           NULL,
	[TargetTime]                  TIME (0)       NULL,
	[TimeSpentFirstLine]          BIGINT         NULL,
	[TotalTime]                   BIGINT         NULL,
	[TimeSpentSecondLine]         BIGINT         NULL,
	[IncidentType]                NVARCHAR (255) NULL,
	[IncidentTypeSTD]             NVARCHAR (100) NULL,
	[SlaAchieved]                 NVARCHAR (255) NULL,
	[DurationAdjustedActualCombi] BIGINT         NULL,
	[SlaAchievedFlag]             INT            NULL,
	[Bounced]                     TINYINT        NULL,
	[HandledByOGD]                BIT            NULL,
	[AgeDays]                     AS             CONVERT(smallint, DATEDIFF(DAY, CreationDate, COALESCE(CompletionDate, GETUTCDATE()))), 
	[AgeWorkDays]                 AS             CONVERT(smallint, CASE WHEN CreationDate = COALESCE(CompletionDate, GETUTCDATE()) THEN 0 WHEN CreationDate > COALESCE(CompletionDate, GETUTCDATE()) THEN NULL ELSE (DATEDIFF(DD, CreationDate, COALESCE(CompletionDate, GETUTCDATE()))) - (DATEDIFF(WW, CreationDate, COALESCE(CompletionDate, GETUTCDATE())) * 2) + (CASE WHEN DATENAME(DW, CreationDate) = 'Saturday' THEN 1 ELSE 0 END) - (CASE WHEN DATENAME(DW, COALESCE(CompletionDate, GETUTCDATE())) = 'Saturday' THEN 1 ELSE 0 END) END),
	[MonthDiffCompletedToToday]   AS             CONVERT(smallint, DATEDIFF(MM, CompletionDate, GETUTCDATE())),
	[MonthDiffClosureToToday]     AS             CONVERT(smallint, DATEDIFF(MM, ClosureDate, GETUTCDATE())),
	CONSTRAINT [PK_Incident] PRIMARY KEY CLUSTERED ([Incident_Id] ASC),
	CONSTRAINT [FK_Incident_CallerKey] FOREIGN KEY ([CallerKey]) REFERENCES [Dim].[Caller] ([CallerKey]),
	CONSTRAINT [FK_Incident_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [Dim].[Customer] ([CustomerKey]),
	CONSTRAINT [FK_Incident_ObjectKey] FOREIGN KEY ([ObjectKey]) REFERENCES [Dim].[Object] ([ObjectKey]),
	CONSTRAINT [FK_Incident_OperatorGroupKey] FOREIGN KEY ([OperatorGroupKey]) REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
)
GO

CREATE NONCLUSTERED INDEX [IX_Incident_CustomerKey]
	ON [Fact].[Incident] ([CustomerKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_Incident_ObjectKey]
	ON [Fact].[Incident] ([ObjectKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_Incident_CallerKey]
	ON [Fact].[Incident] ([CallerKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_Incident_OperatorGroupKey]
	ON [Fact].[Incident] ([OperatorGroupKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_Incident_MultipleKeys]
	ON [Fact].[Incident] ([CustomerKey] ASC, [StatusSTD] ASC, [ClosureDate] ASC, [IncidentDate] ASC)
	INCLUDE ([CallerKey], [OperatorGroupKey], [Category])
GO

CREATE NONCLUSTERED INDEX [IX_Incident_CreationDate]
	ON [Fact].[Incident] ([CreationDate] ASC)
	INCLUDE ([Incident_Id], [CustomerKey], [CompletionDate])
GO

CREATE NONCLUSTERED INDEX [IX_Incident_DateDiffPerCustomerCalc]
	ON [Fact].[Incident] ([CustomerKey] ASC)
	INCLUDE ([Incident_Id], [CompletionDate], [IncidentDate])
GO