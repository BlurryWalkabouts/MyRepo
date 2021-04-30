CREATE TABLE [Fact].[Change]
(
	[Change_Id]                    INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[SourceDatabaseKey]            INT            NOT NULL,
	[AuditDWKey]                   INT            NOT NULL,
	[CustomerKey]                  INT            NOT NULL,
	[CallerKey]                    INT            NOT NULL,
	[OperatorGroupKey]             INT            NOT NULL,
	[Category]                     NVARCHAR (255) NULL,
	[CardChangedBy]                NVARCHAR (255) NULL,
	[ChangeDate]                   DATE           NULL,
	[ChangeTime]                   TIME (0)       NULL,
	[ClosureDateSimpleChange]      DATE           NULL,
	[ClosureTimeSimpleChange]      TIME (0)       NULL,
	[Closed]                       BIT            NULL,
	[CardCreatedBy]                NVARCHAR (255) NULL,
	[CustomerName]                 NVARCHAR (255) NULL,
	[ExternalNumber]               NVARCHAR (255) NULL,
	[Impact]                       NVARCHAR (255) NULL,
	[ChangeNumber]                 NVARCHAR (255) NULL,
	[ObjectID]                     NVARCHAR (255) NULL,
	[Priority]                     NVARCHAR (255) NULL,
	[Status]                       NVARCHAR (255) NULL,
	[Subcategory]                  NVARCHAR (255) NULL,
	[AuthorizationDate]            DATE           NULL,
	[AuthorizationTime]            TIME (0)       NULL,
	[CancelDateExtChange]          DATE           NULL,
	[CancelTimeExtChange]          TIME (0)       NULL,
	[CancelledByManager]           NVARCHAR (255) NULL,
	[CancelledByOperator]          NVARCHAR (255) NULL,
	[ChangeType]                   NVARCHAR (255) NULL,
	[Coordinator]                  NVARCHAR (255) NULL,
	[CreationDate]                 DATE           NULL,
	[CreationTime]                 TIME (0)       NULL,
	[CurrentPhase]                 NVARCHAR (255) NULL,
	[CurrentPhaseSTD]              NVARCHAR (100) NULL,
	[DateCalcTypeEvaluation]       NVARCHAR (255) NULL,
	[DateCalcTypeProgress]         NVARCHAR (255) NULL,
	[DateCalcTypeRequestChange]    NVARCHAR (255) NULL,
	[DescriptionBrief]             NVARCHAR (255) NULL,
	[EndDateExtChange]             DATE           NULL,
	[EndTimeExtChange]             TIME (0)       NULL,
	[Evaluation]                   BIT            NULL,
	[ImplDateExtChange]            DATE           NULL,
	[ImplTimeExtChange]            TIME (0)       NULL,
	[ImplDateSimpleChange]         DATE           NULL,
	[ImplTimeSimpleChange]         TIME (0)       NULL,
	[Implemented]                  BIT            NULL,
	[MajorIncidentId]              NVARCHAR (255) NULL,
	[NoGoDateExtChange]            DATE           NULL,
	[NoGoTimeExtChange]            TIME (0)       NULL,
	[OperatorEvaluationExtChange]  NVARCHAR (255) NULL,
	[OperatorProgressExtChange]    NVARCHAR (255) NULL,
	[OperatorRequestChange]        NVARCHAR (255) NULL,
	[OperatorSimpleChange]         NVARCHAR (255) NULL,
	[OriginalIncident]             NVARCHAR (255) NULL,
	[PlannedAuthDateRequestChange] DATE           NULL,
	[PlannedAuthTimeRequestChange] TIME (0)       NULL,
	[PlannedFinalDate]             DATE           NULL,
	[PlannedFinalTime]             TIME (0)       NULL,
	[PlannedImplDate]              DATE           NULL,
	[PlannedImplTime]              TIME (0)       NULL,
	[PlannedStartDateSimpleChange] DATE           NULL,
	[PlannedStartTimeSimpleChange] TIME (0)       NULL,
	[ProcessingStatus]             NVARCHAR (255) NULL,
	[Rejected]                     BIT            NULL,
	[RejectionDate]                DATE           NULL,
	[RejectionTime]                TIME (0)       NULL,
	[RequestDate]                  DATE           NULL,
	[RequestTime]                  TIME (0)       NULL,
	[StartDateSimpleChange]        DATE           NULL,
	[StartTimeSimpleChange]        TIME (0)       NULL,
	[Started]                      BIT            NULL,
	[SubmissionDateRequestChange]  DATE           NULL,
	[SubmissionTimeRequestChange]  TIME (0)       NULL,
	[Template]                     NVARCHAR (255) NULL,
	[TimeSpent]                    BIGINT         NULL,
	[Type]                         NVARCHAR (255) NULL,
	[TypeSTD]                      NVARCHAR (100) NULL,
	[Urgency]                      BIT            NULL,
	[ClosureDate]                  DATE           NULL,
	[ClosureTime]                  TIME (0)       NULL,
	[CompletionDate]               DATE           NULL,
	[CompletionTime]               TIME (0)       NULL,
	[RequestedBy]                  NVARCHAR (32)  NULL,
	[FirstTimeRight]               BIT            NULL,
	[AgeDays]                      AS             CONVERT(smallint, DATEDIFF(DAY, CreationDate, COALESCE(CompletionDate, GETUTCDATE()))), 
	[AgeWorkDays]                  AS             CONVERT(smallint, CASE WHEN CreationDate = COALESCE(CompletionDate, GETUTCDATE()) THEN 0 WHEN CreationDate > COALESCE(CompletionDate, GETUTCDATE()) THEN NULL ELSE (DATEDIFF(DD, CreationDate, COALESCE(CompletionDate, GETUTCDATE()))) - (DATEDIFF(WW, CreationDate, COALESCE(CompletionDate, GETUTCDATE())) * 2) + (CASE WHEN DATENAME(DW, CreationDate) = 'Saturday' THEN 1 ELSE 0 END) - (CASE WHEN DATENAME(DW, COALESCE(CompletionDate, GETUTCDATE())) = 'Saturday' THEN 1 ELSE 0 END) END),
	[MonthDiffCompletedToToday]    AS             CONVERT(smallint, DATEDIFF(MM, CompletionDate, GETUTCDATE())),
	[MonthDiffClosureToToday]      AS             CONVERT(smallint, DATEDIFF(MM, ClosureDate, GETUTCDATE())),
	SlaAchievedFlag                AS             CASE
                                                 WHEN TypeSTD = 'Wijzigingstraject' AND DATEDIFF(DAY, PlannedFinalDate, ClosureDate) >  0 THEN 0
                                                 WHEN TypeSTD = 'Wijzigingstraject' AND DATEDIFF(DAY, PlannedFinalDate, ClosureDate) <= 0 THEN 1
                                                 WHEN TypeSTD = 'Standaard aanvraag' AND DATEDIFF(DAY, PlannedImplDate,  CompletionDate) >  0 THEN 0
                                                 WHEN TypeSTD = 'Standaard aanvraag' AND DATEDIFF(DAY, PlannedImplDate,  CompletionDate) <= 0 THEN 1
                                                 WHEN ClosureDate IS NULL AND PlannedFinalDate < GETDATE() THEN 0
                                                 WHEN CompletionDate IS NULL AND PlannedImplDate  < GETDATE() THEN 0 
																 END
	CONSTRAINT [PK_Change] PRIMARY KEY CLUSTERED ([Change_Id] ASC),
	CONSTRAINT [FK_Change_CallerKey] FOREIGN KEY ([CallerKey]) REFERENCES [Dim].[Caller] ([CallerKey]),
	CONSTRAINT [FK_Change_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [Dim].[Customer] ([CustomerKey]),
	CONSTRAINT [FK_Change_OperatorGroupKey] FOREIGN KEY ([OperatorGroupKey]) REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
)
GO

CREATE NONCLUSTERED INDEX [IX_Change_MultipleKeys]
	ON [Fact].[Change] ([CustomerKey] ASC, [RequestDate] ASC, [ClosureDate] ASC)
	INCLUDE ([SourceDatabaseKey], [ChangeNumber], [Coordinator], [CurrentPhaseSTD], [TypeSTD], [ClosureTime])
GO

CREATE NONCLUSTERED INDEX [IX_Change_CustomerKey]
	ON [Fact].[Change] ([CustomerKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_Change_CallerKey]
	ON [Fact].[Change] ([CallerKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_Change_OperatorGroupKey]
	ON [Fact].[Change] ([OperatorGroupKey] ASC)
GO