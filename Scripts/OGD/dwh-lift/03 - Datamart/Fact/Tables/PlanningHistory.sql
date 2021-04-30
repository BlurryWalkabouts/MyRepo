/* Planning History is geplande uren op datum X zoals gemeten op datum X */

CREATE TABLE [Fact].[PlanningHistory]
(
	[NominationKey]            INT            NOT NULL,
	[PlanningDate]             DATE           NULL,
	[EstimatedWorkloadDaily]   DECIMAL (9, 2) NULL,
	[EstimatedPlannedTurnover] MONEY          NULL,
	CONSTRAINT [FK_PlanningHistory_NominationKey] FOREIGN KEY ([NominationKey]) REFERENCES [Dim].[Nomination] ([NominationKey]),
	CONSTRAINT [FK_PlanningHistory_Day] FOREIGN KEY ([PlanningDate]) REFERENCES [Dim].[Date] ([Date])
)