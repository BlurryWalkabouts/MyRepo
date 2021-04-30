CREATE VIEW [monitoring].[IncorrectCallers]
AS

WITH cte AS
(
SELECT
	CallerKey
FROM
	[$(OGDW)].Fact.Change
UNION
SELECT
	CallerKey
FROM
	[$(OGDW)].Fact.Incident
)

SELECT
	*
FROM
	[$(OGDW)].Dim.[Caller]
WHERE 1=1
	AND CallerKey NOT IN (SELECT CallerKey FROM cte)