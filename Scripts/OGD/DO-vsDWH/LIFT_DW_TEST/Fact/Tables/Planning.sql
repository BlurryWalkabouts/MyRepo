CREATE TABLE [Fact].[Planning]
(
	[NominationKey]            INT            NOT NULL,
	[PlanningDate]             DATE           NULL,
	[EstimatedWorkloadDaily]   DECIMAL (9, 2) NULL,
	[EstimatedPlannedTurnover] MONEY          NULL,
--	CONSTRAINT [FK_Planning_NominationKey] FOREIGN KEY ([NominationKey]) REFERENCES Dim.[Nomination] ([NominationKey]),
--	CONSTRAINT [FK_Planning_Day] FOREIGN KEY ([PlanningDate]) REFERENCES Dim.[Date] ([Date])
)