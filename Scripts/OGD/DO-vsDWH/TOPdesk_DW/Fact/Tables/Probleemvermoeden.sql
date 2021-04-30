CREATE TABLE [Fact].[ProbleemVermoeden]
(
	[ProbleemVermoeden_ID] INT            NOT NULL,
	[SourceDatabaseKey]    INT            NOT NULL,
	[AuditDWKey]           INT            NOT NULL,
	[CustomerKey]          INT            NOT NULL,
	[IncidentKey]          INT            NOT NULL,
	[CreationDate]         DATE           NULL,
	[CreationTime]         TIME (0)       NULL,
	[OperatorName]         NVARCHAR (255) NULL,
	[Memo]                 NVARCHAR (MAX) NULL,
	CONSTRAINT [PK_ProbleemVermoeden] PRIMARY KEY CLUSTERED ([ProbleemVermoeden_ID] ASC),
	CONSTRAINT [FK_ProbleemVermoeden_IncidentKey] FOREIGN KEY ([IncidentKey]) REFERENCES [Fact].[Incident] ([Incident_Id])
)
GO

CREATE NONCLUSTERED INDEX [IX_ProbleemVermoeden_IncidentKey]
	ON [Fact].[ProbleemVermoeden] ([IncidentKey] ASC)
GO