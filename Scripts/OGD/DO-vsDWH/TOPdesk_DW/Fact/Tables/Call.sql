CREATE TABLE [Fact].[Call]
(
	[CallSummaryID]     BIGINT        NOT NULL,
	[CustomerKey]       INT           NOT NULL,
	[StartDateKey]      CHAR (8)      NULL,
	[StartTimeKey]      INT           NULL,
	[InQueueDateKey]    INT           NULL,
	[InQueueTimeKey]    INT           NULL,
	[AcceptedDateKey]   INT           NULL,
	[AcceptedTimeKey]   INT           NULL,
	[EndDateKey]        INT           NULL,
	[EndTimeKey]        INT           NULL,
	[UCCName]           VARCHAR (255) NULL,
	[Caller]            VARCHAR (255) MASKED WITH (FUNCTION = 'default()') NULL,
	[StartTime]         DATETIME      NULL,
	[InQueueTime]       DATETIME      NULL,
	[AcceptedTime]      DATETIME      NULL,
	[EndTime]           DATETIME      NULL,
	[Accepted]          BIT           NULL,
	[CallDuration]      INT           NULL,
	[CallTotalDuration] INT           NULL,
	[QueueDuration]     INT           NULL,
	[SkillChosen]       VARCHAR (50)  NULL,
	[InitialAgent]      VARCHAR (255) MASKED WITH (FUNCTION = 'default()') NULL,
	[Handled]           BIT           NULL,
	[DWDateCreated]     DATETIME      NULL,
	CONSTRAINT [PK_Call] PRIMARY KEY CLUSTERED ([CallSummaryID] ASC),
	CONSTRAINT [FK_Call_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [Dim].[Customer] ([CustomerKey])
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Fact_Call]
	ON [Fact].[Call] ([StartDateKey] ASC, [CustomerKey] ASC, [CallSummaryID] ASC)
	INCLUDE ([StartTimeKey], [Accepted], [QueueDuration])
GO

CREATE NONCLUSTERED INDEX [IX_Fact_Call_CustomerKey]
	ON [Fact].[Call] ([CustomerKey] ASC)
	INCLUDE ([CallSummaryID], [StartDateKey], [StartTimeKey])
GO

CREATE NONCLUSTERED INDEX [IX_Call_CustomerKey]
	ON [Fact].[Call] ([CustomerKey] ASC)
	INCLUDE ([CallSummaryID], [StartTimeKey], [StartDateKey], [QueueDuration], [Accepted])
GO