CREATE VIEW [Fact].[vwChangeCountsPerDay]
AS

WITH FilteredChanges AS
(
SELECT
	ChangeKey
	, DateCreation
	, DateCompletion
	, DatePlannedImpl
	, [Date]
FROM
	Dim.vwDate
	LEFT OUTER JOIN Fact.vwExtChange ON [Date] >= DateCreation AND ([Date] < DateCompletion OR DateCompletion IS NULL)
)

SELECT
	ChangeKey
	, DateCreation
	, DateCompletion
	, [Date]
	, AgeDays = DATEDIFF(DD,DateCreation,[Date])
	, AgeWorkDays = AgeWorkDays.NumberOfDays -- No weekend and holidays
	, DelayedImplementation = CASE
			WHEN DatePlannedImpl = DATEADD(DD,-1,[Date]) THEN 1
			WHEN DatePlannedImpl IS NOT NULL AND DatePlannedImpl <> [Date] THEN 0
			ELSE NULL
		END
FROM
	FilteredChanges
	CROSS APPLY (SELECT NumberOfDays = dbo.DateDiffDays(DateCreation, [Date], 0, 0)) AgeWorkDays