CREATE TABLE [Fact].[ProcesFeedback]
(
	[ProcesFeedback_ID] INT            NOT NULL,
	[SourceDatabaseKey] INT            NOT NULL,
	[AuditDWKey]        INT            NOT NULL,
	[CustomerKey]       INT            NOT NULL,
	[IncidentKey]       INT            NOT NULL,
	[ChangeKey]         INT            NOT NULL,
	[CreationDate]      DATE           NULL,
	[CreationTime]      TIME (0)       NULL,
	[OperatorName]      NVARCHAR (255) NULL,
	[Memo]              NVARCHAR (MAX) NULL,
	CONSTRAINT [PK_ProcesFeedback] PRIMARY KEY CLUSTERED ([ProcesFeedback_ID] ASC),
	CONSTRAINT [FK_ProcesFeedback_IncidentKey] FOREIGN KEY ([IncidentKey]) REFERENCES [Fact].[Incident] ([Incident_Id]),
	CONSTRAINT [FK_ProcesFeedback_ChangeKey] FOREIGN KEY ([ChangeKey]) REFERENCES [Fact].[Change] ([Change_Id])
)
GO

CREATE NONCLUSTERED INDEX [IX_ProcesFeedback_IncidentKey]
	ON [Fact].[ProcesFeedback] ([IncidentKey] ASC)
GO

CREATE NONCLUSTERED INDEX [IX_ProcesFeedback_ChangeKey]
	ON [Fact].[ProcesFeedback] ([ChangeKey] ASC)
GO