CREATE TABLE [Fact].[OperationalActivity]
(
	[OperationalActivity_Id]     INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[SourceDatabaseKey]          INT            NOT NULL,
	[AuditDWKey]                 INT            NOT NULL,
	[CustomerKey]                INT            NOT NULL,
	[OperatorGroupKey]           INT            NOT NULL,
	[OperatorKey]                INT            NOT NULL,
	[Projected]                  BIT            NULL,
	[OperationalSeriesNumber]    NVARCHAR (30)  NULL,
	[OperationalActivityNumber]  NVARCHAR (30)  NULL,
	[OperationalActivityName]    NVARCHAR (80)  NULL,
	[Status]                     INT            NULL,
	[CreationDate]               DATE           NULL,
	[CreationTime]               TIME (0)       NULL,
	[ChangeDate]                 DATE           NULL,
	[ChangeTime]                 TIME (0)       NULL,
	[PlannedStartDate]           DATE           NULL,
	[PlannedStartTime]           TIME (0)       NULL,
	[PlannedFinalDate]           DATE           NULL,
	[PlannedFinalTime]           TIME (0)       NULL,
	[ClosureDate]                DATE           NULL,
	[ClosureTime]                TIME (0)       NULL,
	[Closed]                     BIT            NULL,
	[Skipped]                    BIT            NULL,
	[TimeSpent]                  BIGINT         NULL,
	CONSTRAINT [PK_OperationalActivity] PRIMARY KEY CLUSTERED ([OperationalActivity_Id] ASC),
	CONSTRAINT [FK_OperationalActivity_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [Dim].[Customer] ([CustomerKey]),
	CONSTRAINT [FK_OperationalActivity_OperatorGroupKey] FOREIGN KEY ([OperatorGroupKey]) REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey]),
	CONSTRAINT [FK_OperationalActivity_OperatorKey] FOREIGN KEY ([OperatorKey]) REFERENCES [Dim].[OperatorGroup] ([OperatorGroupKey])
)
GO

CREATE NONCLUSTERED INDEX [IX_OperationalActivity_CustomerKey]
	ON [Fact].[OperationalActivity] ([CustomerKey] ASC)
GO