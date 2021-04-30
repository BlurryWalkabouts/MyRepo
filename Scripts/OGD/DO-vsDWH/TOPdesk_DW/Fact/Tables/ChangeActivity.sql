CREATE TABLE [Fact].[ChangeActivity]
(
	[ChangeActivity_Id]          INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[SourceDatabaseKey]          INT            NOT NULL,
	[AuditDWKey]                 INT            NOT NULL,
	[ChangeKey]                  INT            NOT NULL,
	[CustomerKey]                INT            NOT NULL,
	[OperatorGroupKey]           INT            NOT NULL,
	[OperatorKey]                INT            NOT NULL,
	[ChangeDate]                 DATE           NULL,
	[ChangeTime]                 TIME (0)       NULL,
	[Approved]                   BIT            NULL,
	[ApprovedDate]               DATE           NULL,
	[ApprovedTime]               TIME (0)       NULL,
	[BriefDescription]           NVARCHAR (255) NULL,
	[CurrentPlanTimeTaken]       BIGINT         NULL,
	[CreationDate]               DATE           NULL,
	[CreationTime]               TIME (0)       NULL,
	[ActivityNumber]             NVARCHAR (255) NULL,
	[OriginalPlanTimeTaken]      BIGINT         NULL,
	[ChangePhase]                INT            NULL,
	[PlannedFinalDate]           DATE           NULL,
	[PlannedFinalTime]           TIME (0)       NULL,
	[PlannedStartDate]           DATE           NULL,
	[PlannedStartTime]           TIME (0)       NULL,
	[Rejected]                   BIT            NULL,
	[RejectedDate]               DATE           NULL,
	[RejectedTime]               TIME (0)       NULL,
	[Resolved]                   BIT            NULL,
	[ResolvedDate]               DATE           NULL,
	[ResolvedTime]               TIME (0)       NULL,
	[Skipped]                    BIT            NULL,
	[SkippedDate]                DATE           NULL,
	[SkippedTime]                TIME (0)       NULL,
	[Closed]                     BIT            NULL,
	[ClosureDate]                DATE           NULL,
	[ClosureTime]                TIME (0)       NULL,
	[Started]                    BIT            NULL,
	[StartedDate]                DATE           NULL,
	[StartedTime]                TIME (0)       NULL,
	[TimeTaken]                  BIGINT         NULL,
	[MayStart]                   BIT            NULL,
	[ChangeBriefDescription]     NVARCHAR (255) NULL,
	[ActivityTemplate]           NVARCHAR (255) NULL,
	[Category]                   NVARCHAR (255) NULL,
	[ActivityChange]             NVARCHAR (255) NULL,
	[Subcategory]                NVARCHAR (255) NULL,
	[CardCreatedBy]              NVARCHAR (255) NULL,
	[CardChangedBy]              NVARCHAR (255) NULL,
	[Status]                     NVARCHAR (255) NULL,
	[ProcessingStatus]           NVARCHAR (255) NULL,
	[DurationActual]             BIGINT         NULL,
	[DurationPlanned]            BIGINT         NULL,
	[MaxPreviousActivityEndDate] DATETIME       NULL,
	[ChangePhaseStartDate]       DATETIME       NULL,
	[Level]                      TINYINT        NULL,
	[PlannedStartRank]           INT            NULL,
	[MonthDiffClosureToToday]    AS             CONVERT(smallint, DATEDIFF(MM, ClosureDate, GETUTCDATE())),
	[DurationDifference]         AS             DurationPlanned - DurationActual
	CONSTRAINT [PK_ChangeActivity] PRIMARY KEY CLUSTERED ([ChangeActivity_Id] ASC),
	CONSTRAINT [FK_ChangeActivity_ChangeKey] FOREIGN KEY ([ChangeKey]) REFERENCES [Fact].[Change] ([Change_Id]),
	CONSTRAINT [FK_ChangeActivity_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [Dim].[Customer] ([CustomerKey]),
	CONSTRAINT [FK_ChangeActivity_OperatorGroupKey] FOREIGN KEY ([OperatorGroupKey]) REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
)
GO

CREATE NONCLUSTERED INDEX [IX_ChangeActivity_CallerKey]
	ON [Fact].[ChangeActivity] ([ChangeKey] ASC)
	INCLUDE ([OperatorGroupKey], [CustomerKey])
GO

CREATE NONCLUSTERED INDEX [IX_ChangeActivity_ChangeKey]
	ON [Fact].[ChangeActivity] ([ChangeKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_ChangeActivity_CustomerKey]
	ON [Fact].[ChangeActivity] ([CustomerKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_Fact_MultipleKeys]
	ON [Fact].[ChangeActivity] ([SourceDatabaseKey] ASC, [ActivityChange] ASC)
	INCLUDE ([ResolvedDate], [ResolvedTime], [SkippedDate], [SkippedTime])
GO

CREATE NONCLUSTERED INDEX [IX_ChangeActivity_MultipleKeys]
	ON [Fact].[ChangeActivity] ([CustomerKey] ASC)
	INCLUDE ([OperatorGroupKey], [ChangeKey], [ChangePhase], [PlannedFinalDate], [PlannedFinalTime], [PlannedStartDate], [PlannedStartTime], [RejectedDate], [RejectedTime], [ResolvedDate], [ResolvedTime], [SkippedDate], [SkippedTime], [Category], [Subcategory], [MaxPreviousActivityEndDate], [ChangePhaseStartDate])
GO