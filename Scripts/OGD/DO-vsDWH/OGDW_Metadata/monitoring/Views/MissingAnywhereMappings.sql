CREATE VIEW [monitoring].[MissingAnywhereMappings]
AS

WITH AnywhereSkills AS
(
SELECT DISTINCT
	skillChosen
FROM
	[$(OGDW_Staging)].Anywhere365_UCC.UCC_CallSummary
)

, AnywhereMappings AS
(
SELECT
	[Name]
FROM
	setup.AnywhereSkillTranslation
)

SELECT
	*
FROM
	AnywhereSkills
WHERE 1=1
	AND NOT EXISTS (SELECT [Name] FROM AnywhereMappings WHERE skillChosen = [Name])
	AND skillChosen <> ''