CREATE VIEW [setup].[AnywhereSkillTranslation]
AS
SELECT
	ID
	, [Name]
	, Code
	, Customer_Code
	, Customer_Name
	, Customer_ID
	, Map
FROM
	[$(MDS)].mdm.AnywhereSkillTranslation